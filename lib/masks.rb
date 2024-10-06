# frozen_string_literal: true

# Top-level module for masks.
module Masks
  class << self
    def url=(value)
      @url = value
    end

    def url
      @url || ENV["MASKS_URL"]
    end

    def installation
      @installation ||=
        Masks::Installation.order(created_at: :desc).last ||
          Masks::Installation.new
    end

    def install!
      return unless installation.new_record?

      installation.seed!

      yield installation if block_given?
    end

    def reset!
      @installation&.destroy!
      @installation = nil
    end
  end
end
