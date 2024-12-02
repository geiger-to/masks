# frozen_string_literal: true

module Types
  class ClientInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :name, String, required: false
    argument :secret, String, required: false
    argument :bg_dark, String, required: false
    argument :bg_light, String, required: false
    argument :type, String, required: false
    argument :subject_type, String, required: false
    argument :redirect_uris, String, required: false
    argument :scopes, GraphQL::Types::JSON, required: false
    argument :checks, [String], required: false
    argument :sector_identifier, String, required: false
    argument :pairwise_salt, String, required: false

    Masks::Client::BOOLEAN_COLUMNS.each do |col|
      argument col, Boolean, required: false
    end

    Masks::Client::LIFETIME_COLUMNS.each do |col|
      argument col, String, required: false
    end
  end
end
