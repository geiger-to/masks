# frozen_string_literal: true

module Mutations
  class Logout < BaseMutation
    input_object_class Types::LogoutInputType

    field :total, Integer, null: true
    field :errors, [String], null: true

    def resolve(**args)
      devices =
        if args[:actor]
          find_by_actor(args[:actor])
        elsif args[:device]
          find_by_device(args[:device])
        else
          []
        end

      devices.each(&:logout!)

      { total: devices.length, errors: [] }
    end

    private

    def find_by_device(public_id)
      Masks::Device.where(public_id:)
    end

    def find_by_actor(identifier)
      Masks.find(identifier)&.devices
    end
  end
end
