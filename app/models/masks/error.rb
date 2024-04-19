# frozen_string_literal: true

module Masks
  module Error
    # Base class for Masks errors
    class Base < RuntimeError
    end

    # Thrown when a session is required but not provided
    class InvalidSession < Base
      def initialize
        super("a session was expected, but none was provided")
      end
    end

    # Thrown when invalid configuration is detected
    class InvalidConfiguration < Base
      def initialize(value)
        super("cannot use '#{value}' for masks.json")
      end
    end

    # Thrown when configuration is not found
    class ConfigurationNotFound < Base
      def initialize
        super("cannot find masks.json")
      end
    end

    # Thrown when Masks encounters an unauthorized session
    class Unauthorized < Base
      def initialize
        super("unauthorized")
      end
    end

    # Thrown when Masks cannot find a mask for a session
    class UnknownMask < Base
      def initialize(session)
        super("could not determine mask for #{session}")
      end
    end

    # Thrown when Masks cannot find an access class for the given name
    class UnknownAccess < Base
      def initialize(name)
        super("could not determine access class for #{name}")
      end
    end

    # Thrown when Masks has failed its credential checks
    class CheckFailed < Base
      def initialize(cred)
        super("failed checking #{cred.check} with #{cred.class}")
      end
    end
  end
end
