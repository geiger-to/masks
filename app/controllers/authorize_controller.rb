class AuthorizeController < AuthorizedController
  def new
    history.start!

    @props = { section: "Authorize", auth_id: history.auth_id }

    headers["X-Masks-Auth-Id"] = history.auth_id

    respond_to { |format| format.html { render "app" } }
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
