module Masks
  module OneTimePasswordable
    extend ActiveSupport::Concern

    class_methods do
      cattr_accessor :otp_config

      def otp_code(column: "otp", &block)
        self.otp_config ||= {}
        self.otp_config[name] ||= {}
        self.otp_config[name][column] ||= {}
        self.otp_config[name][column].merge!(block:) if block_given?
        self.otp_config[name][column].merge!(
          secret_column: "#{column}_secret",
          time_column: "last_#{column}_at",
        )

        after_initialize { populate_otp_secret(column) }
      end
    end

    def otp_issuer
      Masks.installation.name
    end

    def verify_otp!(code, column = "otp")
      verified =
        otp(column).verify(
          code,
          drift_behind: otp_interval(column),
          after: self[otp_config(column)[:time_column]],
        )
      update(otp_config(column)[:time_column] => Time.current) if verified
      verified
    end

    def otp(column = "otp")
      return unless otp_secret_value(column)

      ROTP::TOTP.new(otp_secret_value(column), issuer: otp_issuer, interval: 60)
    end

    def otp_code(column = "otp")
      otp&.now
    end

    def otp_code_parts(column = "otp")
      code = otp&.now
      [code.slice(0, 3), code.slice(3, 6)] if code
    end

    def otp_config(column = "otp")
      unless data = self.class.otp_config.dig(self.class.name, column)
        raise "invalid OTP column: #{column}"
      end

      @otp_config ||= {}
      @otp_config[column] ||= begin
        config = (instance_exec(&data[:block]) if data[:block])

        (config || {}).merge(data)
      end
    end

    def otp_interval(column = "otp")
      otp_config(column).dig(:interval)
    end

    def otp_secret_value(column = "otp")
      self[otp_config(column).dig(:secret_column)]
    end

    def populate_otp_secret(column)
      self[otp_config(column).dig(:secret_column)] ||= random_otp_secret
    end

    def random_otp_secret
      @random_otp_secret ||= ROTP::Base32.random
    end
  end
end
