# frozen_string_literal: true

module Masks
  class Device < ApplicationRecord
    self.table_name = "masks_devices"

    has_many :access_tokens, class_name: "Masks::AccessToken"
    has_many :authorizations, class_name: "Masks::Authorization"
    has_many :clients, through: :access_tokens, class_name: "Masks::Client"
    has_many :actors, through: :access_tokens, class_name: "Masks::Actor"

    validates :key, presence: true, uniqueness: true
    validates :known?, :user_agent, presence: true
    validates :ip_address, ip: true

    after_initialize :generate_key

    delegate :name, :device_type, :device_name, :os_name, :known?, to: :detected

    private

    def generate_key
      self.key ||= SecureRandom.uuid
    end

    def detected
      @detected ||= DeviceDetector.new(user_agent) if user_agent
    end
  end
end
