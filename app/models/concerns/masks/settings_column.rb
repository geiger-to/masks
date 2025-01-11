module Masks
  module SettingsColumn
    extend ActiveSupport::Concern

    included do
      include GraphQL

      serialize :settings, coder: JSON

      after_initialize :generate_settings
    end

    class_methods do
      def settings(**config)
        @settings ||= {}
        @settings[self.name] ||= {}
        @settings[self.name].merge!(config.stringify_keys)

        config.keys.each do |key|
          define_method key do
            setting(key)
          end

          define_method "#{key}=" do |value|
            self.settings ||= {}
            self.settings[key.to_s] = value
          end

          define_method "#{key}?" do
            !!setting(key)&.present?
          end
        end

        @settings[self.name]
      end
    end

    def setting(*names, default: nil)
      setting = (settings || {}).dig(*names.map(&:to_s))
      setting || default
    end

    def setting!(name, value)
      self.settings[name.to_s] = value
    end

    def merge_settings(updates)
      updates =
        if self.class.settings.keys.any?
          updates.deep_stringify_keys.slice(*self.class.settings.keys)
        else
          updates.deep_stringify_keys
        end

      self.settings = self.settings.deep_stringify_keys.deep_merge(updates)
    end

    private

    def generate_settings
      self.settings ||= {}
    end
  end
end
