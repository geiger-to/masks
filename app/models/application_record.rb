class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :latest, -> { order(created_at: :desc) }

  class << self
    def generate_key(from:)
      before_validation unless: :key, on: :create do
        generate_key_from(try(from))
      end
    end
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def generate_key_from(name)
    return unless name&.present?

    key = name.parameterize

    loop do
      break if self.class.where(key:).none?

      key = "#{name.parameterize}-#{SecureRandom.hex([*1..4].sample)}"
    end

    self.key = key
  end
end
