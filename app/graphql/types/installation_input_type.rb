# frozen_string_literal: true

module Types
  class InstallationInputType < Types::BaseInputObject
    argument :name, String, required: false
    argument :owner, String, required: false
    argument :contact, String, required: false
  end
end
