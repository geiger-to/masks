# frozen_string_literal: true

# Top-level module for masks.
module Masks
  class << self
    def installation
      @installation ||=
        Masks::Installation
          .where(expired_at: nil)
          .order(created_at: :desc)
          .last || Masks::Installation.new
    end

    def install!
      return unless installation.new_record?

      installation.seed!

      yield installation if block_given?
    end
  end
end
