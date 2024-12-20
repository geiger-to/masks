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
        end

      record.destroy
    end
  end
end
