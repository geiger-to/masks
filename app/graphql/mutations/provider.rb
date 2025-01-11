# frozen_string_literal: true

module Mutations
  class Provider < BaseMutation
    input_object_class Types::ProviderInputType

    field :provider, Types::ProviderType, null: true
    field :errors, [String], null: true

    def resolve(**args)
      provider =
        if args[:id]
          Masks::Provider
            .find_by(key: args[:id])
            &.tap do |p|
              p.name = args[:name] if args[:name]
              p.settings = args[:settings] if args[:settings]
              p.common = args[:common] if args.key?(:common)
            end
        else
          type = Masks::Provider::TYPE_MAP.fetch(args[:type])
          attrs = args.slice(:name, :settings, :common)

          Masks::Provider.new(type:, disabled_at: Time.current, **attrs)
        end

      provider&.disable if args[:disabled]
      provider&.enable if args[:enabled]
      provider&.save

      { provider:, errors: provider&.errors&.full_messages }
    end
  end
end
