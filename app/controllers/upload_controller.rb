class AuthorizeController < AuthorizedController
  delegate :actor, to: :authorization, allow_nil: true

  authorized(only: :logo) do
    actor && authorization&.scopes&.include?(Masks::Scoped::MANAGE)
  end

  authorized(only: :avatar) do
    false
    # actor && authorization&.scopes&.include?(Masks::Scoped::MANAGE)
  end

  def avatar
  end

  def logo
  end

  private

  def client
    @client ||=
      (Masks::Client.find_by(key: params[:client_id]) if params[:client_id])
  end
end
