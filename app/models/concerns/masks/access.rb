module Masks
  # Concern to help with building access classes.
  #
  # Access classes must include this module, which will result in the class
  # behaving like an +ActiveModel+ instance, with attributes, validations, and
  # json serialization available by default.
  #
  # After including the module, classes must call +access+ to register the
  # class and its canonical name.
  #
  # @example
  #     class ExampleAccess
  #       include Masks::Access
  #
  #       access 'example'
  #
  #       def say_hi
  #         puts 'hello world!'
  #       end
  #     end
  #
  #     # Later, this class can be accessed with a valid session,
  #     # provided there is a corresponding mask that allows it.
  #     access = Masks.access('example', session)
  #     access.say_hi if access
  #
  # @see Masks::Access::ClassMethods
  module Access
    extend ActiveSupport::Concern

    class << self
      # @visibility private
      def classes
        @classes ||= {}
      end

      # @visibility private
      def register(name, **defaults)
        classes[name.to_s] = defaults
      end

      # @visibility private
      def defaults(name)
        classes.fetch(name.to_s, nil)
      end
    end

    included do
      attr_accessor :session

      def actor
        raise Masks::Error::InvalidSession unless session

        session.scoped || session.actor
      end

      delegate :configuration,
               :roles,
               :has_role?,
               :role_records,
               :scopes,
               :has_scope?,
               :params,
               to: :session

      delegate :access_config, to: :class
    end

    module ClassMethods
      # Overrides `new` to ensure classes are constructed with proper access.
      # @visibility private
      def new(*args, **opts)
        original =
          if args[0] && args[0].is_a?(Masks::Session)
            args.delete_at(0)
          elsif opts[:session]
            opts.delete(:session)
          else
            raise Masks::Error::InvalidSession
          end

        model = original.config.model(:access)
        session = model.new(name: access_name, original: original)
        session.mask!

        raise Masks::Error::Unauthorized unless session.passed?

        instance = super(*args, **opts)
        instance.session = session
        instance
      end

      # Returns the canonical access name for the class.
      #
      # @return [String]
      def access_name
        @access_name
      end

      # Registers the class by the supplied name.
      #
      # Any +opts+ provided will be used as defaults for instances,
      # in addition to the data supplied in the app's configuration.
      #
      # This can be called multiple times. If names are the same, +opts+
      # will be deep merged together. Different names can be supplied as
      # well.
      #
      # @param [String] name
      # @param [Hash] opts
      # @return [nil]
      def access(name, **opts)
        @access_name = name

        Masks::Access.register(access_name, **opts.merge(cls: self))

        nil
      end

      # Returns the configuration for the class.
      #
      # This is a combination of data provided to +access+ along with whatever
      # is specifed in the configuration object for the access class.
      #
      # @return [String]
      def access_config
        Masks.configuration.access(access_name)
      end

      # Builds a new access class, given a variety of arguments.
      #
      # @overload  build(request)
      #   @param [ActionDispatch::Request] request
      # @overload  build(controller)
      #   @param [ActionController::Metal] controller
      # @overload  build(session)
      #   @param [Masks::Session] session
      # @overload  build(actor)
      #   @param [Masks::Actor] actor
      # @overload  build(**attrs)
      #   @param [ActionController::Metal] controller
      # @return [Masks::Access]
      def build(arg1 = nil, **args)
        access =
          case arg1
          when ActionDispatch::Request
            new(session: Masks::Sessions::Request.new(session: arg1))
          when ActionController::Metal
            new(session: arg1.send(:masked_session))
          when Masks::Session
            new(session: arg1, **args)
          when Masks::Actor
            new(session: Masks::Sessions::Actor.new(arg1, **opts))
          when nil
            new(**opts)
          end

        access
      end
    end
  end
end
