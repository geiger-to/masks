# frozen_string_literal: true

module Masks
  class Profile < ApplicationRecord
    self.table_name = "masks_profiles"

    SETTINGS = %w[
      url
      name
      logo
      theme
      background
      favicon
      signups.enabled
      logins.enabled
      dark_mode.logo
      dark_mode.theme
      dark_mode.background
      nickname.prefix
      nickname.enabled
      nickname.signups
      nickname.minimum
      nickname.maximum
      email.enabled
      email.signups
      phone.enabled
      phone.signups
      password.enabled
      password.minimum
      password.maximum
    ]

    belongs_to :tenant, class_name: 'Masks::Tenant'
    has_many :clients, class_name: 'Masks::Client'

    validates :key,
              presence: true,
              uniqueness: true

    validates :identifiers, presence: true

    serialize :settings, coder: JSON

    def to_param
      key
    end

    def name
      super || setting(:name)
    end

    delegate :find_actor, to: :tenant

    def identifiers_key
      if identifiers.keys.any?
        identifiers.keys.sort.join('_')
      else
        'none'
      end
    end

    def identifiers
      tenant.identifiers.map do |key, cls|
        if enabled?(key)
          [key, cls]
        end
      end.compact.to_h.with_indifferent_access
    end

    def signup_identifiers
      identifiers.map do |key, value|
        [key, value] if setting(key, :signups)
      end.compact.to_h
    end

    def optional_identifiers
      identifiers.map do |key, value|
        [key, value] unless setting(key, :signups)
      end.compact.to_h
    end

    def identifier(value:, key: nil)
      tenant.identifier(value:, key:, identifiers:, profile: self)
    end

    def setting(*args)
      merged_settings.dig(*args.map(&:to_s))
    end

    def setting!(*args, value:)
      return if value&.presence == setting(*args).presence

      hash = {}
      len = args.length

      args.each_with_index do |arg, i|
        if i == (len - 1)
          hash[arg] = value
        else
          hash = (hash[arg] ||= {})
        end
      end

      self.settings = settings.deep_merge(hash)
    end

    def enabled?(key)
      setting(key, :enabled)
    end

    def merged_settings
      tenant.settings.deep_stringify_keys.deep_merge(settings.deep_stringify_keys)
    end
  end
end
