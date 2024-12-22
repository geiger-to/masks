# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Auth API
    field :authenticate, mutation: Mutations::Authenticate

    # Admin features
    field :email, mutation: Mutations::Email, managers_only: true
    field :phone, mutation: Mutations::Phone, managers_only: true
    field :otp_secret, mutation: Mutations::OtpSecret, managers_only: true
    field :hardware_key, mutation: Mutations::HardwareKey, managers_only: true
    field :actor, mutation: Mutations::Actor, managers_only: true
    field :client, mutation: Mutations::Client, managers_only: true
    field :device, mutation: Mutations::Device, managers_only: true
    field :install, mutation: Mutations::Installation, managers_only: true
    field :deletion, mutation: Mutations::Deletion, managers_only: true
  end
end
