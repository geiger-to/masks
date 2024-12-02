class AuthorizeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "auth_#{params[:id]}"
  end
end
