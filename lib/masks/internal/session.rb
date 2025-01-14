module Masks
  module Internal
    class Session
      attr_reader :env, :bag

      def initialize(env)
        @env = env
        @bags = {}
      end

      def flags
        @flags ||= {}
      end

      def flag!(name, value = true)
        flags[name.to_s] = !!value
      end

      def flag?(name)
        flags[name.to_s]
      end

      def bag(name, **args)
        if args.keys.any?
          raise "cannot overwrite bag #{name}" if @bags[name.to_sym]

          @bags[name.to_sym] = Bag.new(self, name, **args)
        else
          @bags.fetch(name.to_sym, nil)
        end
      end

      def method_missing(name, *args, **opts)
        if @bags[name.to_sym]
          bag(name)
        elsif name.to_s.start_with?("current_")
          bag(name.to_s.slice(8...).pluralize)&.current
        else
          raise NotImplementedError, name
        end
      end

      def data
        rails_session["_masks"] ||= {}
      end

      def rails_request
        @rails_request ||= ActionDispatch::Request.new(env)
      end

      def rails_session
        @rails_session ||= env["rack.session"]
      end
    end

    class Bag
      EXPIRY_KEY = "-masks-expiry-"
      DEFAULT_KEY = "-masks-default-"

      attr_reader :session, :name, :args

      def initialize(session, name, **args)
        @session = session
        @name = name
        @args = args
      end

      def key
        if current.respond_to?(:session_key)
          current&.try(:session_key) || DEFAULT_KEY
        else
          current || DEFAULT_KEY
        end
      end

      def lifetime
        return args[:expiry] if args[:expiry]

        current.respond_to?(:session_lifetime) ? current.session_lifetime : nil
      end

      def current=(value)
        args[:current] = value
      end

      def current
        args[:current]
      end

      def ns
        name.to_s
      end

      def record
        args[:current]
      end

      def data
        @data ||=
          begin
            data =
              (args[:parent] ? session.bag(args[:parent]).data : session.data)

            data[ns] ||= {}
            data[ns][key] ||= {}

            expiry = data.dig(ns, key, EXPIRY_KEY)
            expired = expiry && Masks.time.expired?(expiry)

            data[ns][key] = {} if expired

            data[ns][key][EXPIRY_KEY] = lifetime
            data[ns][key]
          end
      end

      def refresh(expiry, *args)
        if args.any?
          expiring(args[0], expiring(args[0], ignore_expiry: true), expiry:)
        else
          data[EXPIRY_KEY] = expiry
        end
      end

      def expire(key = nil)
        key ? data[key.to_s].clear : data.clear
      end

      def expiry(key = nil)
        key ? fetch(key, {}).fetch(EXPIRY_KEY, nil) : data[EXPIRY_KEY]
      end

      def expiring(*args, **opts)
        key = args[0].to_s
        expire = !opts.delete(:ignore_expiry)

        self[key] = { EXPIRY_KEY => opts[:expiry], :value => args[1] } if args[
          1
        ]
        self[key] if !expire || expired?(key)
      end

      def expired?(key)
        Masks.time.expired?(data.dig(key.to_s, EXPIRY_KEY))
      end

      def fetch(*args)
        data&.fetch(*args)
      end

      def overwrite(hash, expiry: nil)
        expiry = expiry || self[EXPIRY_KEY]
        data.clear.merge!(hash, { expiry: })
      end

      def dig(*args)
        data.dig(*args.map(&:to_s))
      end

      def [](key)
        data[key.to_s]
      end

      def []=(key, value)
        data[key.to_s] = value
      end
    end
  end
end
