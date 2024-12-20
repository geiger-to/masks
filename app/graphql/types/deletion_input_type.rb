# frozen_string_literal: true

module Types
  class DeletionInputType < Types::BaseInputObject
    argument :id, String, required: true
    argument :type, String, required: true
  end
end
