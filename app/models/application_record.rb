class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :latest, -> { order(created_at: :desc) }

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
