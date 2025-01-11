# frozen_string_literal: true

module Mutations
  class Deletion < BaseMutation
    input_object_class Types::DeletionInputType

    field :errors, [String], null: true

    def resolve(id:, type:)
      record =
        case type
        when "Device"
          Masks::Device.find_by(public_id: id)
        when "Token"
          Masks::Token.find_by(key: id)
        when "Provider"
          Masks::Provider.find_by(key: id)
        end

      record.destroy if record&.valid?(:deletion)

      { errors: nil }
    end
  end
end
