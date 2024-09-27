# frozen_string_literal: true

module Types
  class ActorInputType < Types::BaseInputObject
    argument :signup, Boolean, required: false
    argument :nickname, String, required: true
    argument :password, String, required: false
    argument :scopes, String, required: false
  end
end
