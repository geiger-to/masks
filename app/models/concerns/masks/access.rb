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
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes
      include ActiveModel::Serializers::JSON

      attribute :session

      def initialize(**attrs)
        raise Masks::Error::InvalidSession unless attrs[:session]

        session =
          Masks::Sessions::Access.new(
            name: self.class.access_name,
            original: attrs[:session]
          )
        session.mask!

        raise Masks::Error::Unauthorized unless session.passed?

        super(attrs.merge(session: session))
      end

      delegate :actor, :configuration, to: :session
      delegate :opts, to: :class

      def model
        opts.fetch(:model, nil)
      end
    end

    module ClassMethods
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
      def build(arg1 = nil, **opts)
        access =
          case arg1
          when ActionDispatch::Request
            new(session: Masks::Sessions::Request.new(session: arg1))
          when ActionController::Metal
            new(session: arg1.send(:current_session))
          when Masks::Session
            new(session: arg1, **opts)
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
