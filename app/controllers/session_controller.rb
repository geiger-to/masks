class SessionController < ApplicationController
  private

  def history_group
    session[:history_group] ||= SecureRandom.uuid
  end

  def history
    @history ||= Masks::History.new
  end

  def authorization
    @authorization ||= Masks::Authorization.new(client:, device:, actor:)
  end

  def client
    @client ||=
      Masks::Client.find_by(
        key: params[:client_id],
        client_type: %w[public confidential],
      )
  end
end
