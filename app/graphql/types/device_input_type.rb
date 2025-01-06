# frozen_string_literal: true

module Types
  class DeviceInputType < Types::BaseInputObject
    argument :id, String, required: false
    argument :block, Boolean, required: false
    argument :unblock, Boolean, required: false
    argument :rotate, Boolean, required: false
  end
end
