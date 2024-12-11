# frozen_string_literal: true

module Types
  class SecondFactorType < Types::BaseUnion
    possible_types HardwareKeyType, PhoneType, OtpSecretType

    def self.resolve_type(object, _context)
      case object
      when Masks::HardwareKey
        HardwareKeyType
      when Masks::Phone
        PhoneType
      when Masks::OtpSecret
        OtpSecretType
      else
        raise "invalid object #{object}"
      end
    end
  end
end
