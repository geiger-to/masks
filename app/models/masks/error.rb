module Masks
  module Error
    class Base < RuntimeError
    end

    class InvalidSession < Base
      def initialize
        super "a session was expected, but none was provided"
      end
    end

    class InvalidConfiguration < Base
      def initialize(value)
        super "cannot use '#{value}' for masks.json"
      end
    end

    class ConfigurationNotFound < Base
      def initialize
        super "cannot find masks.json"
      end
    end

    class Unauthorized < Base
      def initialize
        super "unauthorized"
      end
    end

    class UnknownMask < Base
      def initialize(session)
        super "could not determine mask for #{session.to_s}"
      end
    end

    class UnknownAccess < Base
      def initialize(name)
        super "could not determine access class for #{name}"
      end
    end
  end
end
