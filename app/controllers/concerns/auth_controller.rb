module AuthController
  extend ActiveSupport::Concern

  included do
    attr_accessor :client

    around_action { |controller, block| auth.session!(&block) }

    delegate :device, to: :auth
  end

  private

  def auth
    @auth ||= Masks::Auth.new(request:, client:)
  end

  def current_manager
    auth.manager
  end
end
