# frozen_string_literal: true

module Masks
  class Device < ApplicationRecord
    self.table_name = "masks_devices"

    has_many :events, class_name: "Masks::Event"
    has_many :access_tokens, class_name: "Masks::AccessToken"
    has_many :authorization_codes, class_name: "Masks::AuthorizationCode"
    has_many :clients, through: :events, class_name: "Masks::Client"
    has_many :actors, through: :events, class_name: "Masks::Actor"

    validates :session_id, presence: true, uniqueness: true
    validates :known?, :user_agent, presence: true
    validates :ip_address, ip: true

    delegate :name,
             :device_type,
             :device_name,
             :os_name,
             :known?,
             to: :detected,
             allow_nil: true

    private

    def detected
      @detected ||= DeviceDetector.new(user_agent) if user_agent
    end
  end
end
