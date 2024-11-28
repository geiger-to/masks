class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :latest, -> { order(created_at: :desc) }

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def obfuscate(key)
    return unless self[key]

    parts = self[key].split("-")

    obfuscated_parts =
      parts.each_with_index.map do |part, index|
        if index == 0
          part[0, 3] + "*" * (part.length - 3)
        elsif index == parts.size - 1
          "*" * (part.length - 3) + part[-3, 3]
        else
          "*" * part.length
        end
      end

    obfuscated_parts.join("-")
  end
end
