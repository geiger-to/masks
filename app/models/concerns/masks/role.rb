module Masks
  # An interface that all roles should adhere to.
  #
  # @see Masks::Rails::Role Masks::Rails::Role
  module Role
    def actor
      super
    end

    def record
      super
    end
  end
end
