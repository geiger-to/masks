# frozen_string_literal: true

module Mutations
  class Installation < BaseMutation
    input_object_class Types::InstallationInputType

    field :install, Types::InstallationType, null: false
    field :errors, [String], null: true

    def resolve(**args)
      install = Masks.installation.reload
      install.modify(args)
      install.save

      { install:, errors: install.errors.full_messages }
    end
  end
end
