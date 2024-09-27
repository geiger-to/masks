class AuthorizeController < AuthorizedController
  def new
    @props = {
      section: "Authorize",
      client_id: client.to_gqlid,
      redirect_uri: params[:redirect_uri] || client.default_redirect_uri,
    }

    render "app"
  end

  private

  def client
    @client ||=
      if params[:client_id]
        Masks::Client.find_by(key: params[:client_id])
      else
        Masks::Client.default
      end
  end
end
