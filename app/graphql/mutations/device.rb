# frozen_string_literal: true

module Mutations
  class Device < BaseMutation
    input_object_class Types::DeviceInputType

    field :device, Types::DeviceType, null: true
    field :errors, [String], null: true

    def resolve(**args)
      device = Masks::Device.find_by(public_id: args[:id])

      if device
        device.logout if args[:logout]

        if args[:block]
          device.block
        elsif args[:unblock]
          device.unblock
        end

        device.save
      end

      { errors: device&.errors&.full_messages, device: }
    end
  end
end
