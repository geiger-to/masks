class AuthorizeController < AuthorizedController
  def new
    history.start!

    # if oidc_request
    # oidc_request.perform

    # _status, header, = oidc_request.response

    # if header["WWW-Authenticate"].present?
    # headers["WWW-Authenticate"] = header["WWW-Authenticate"]
    # end

    # if header["Location"]
    # return redirect_to header["Location"], allow_other_host: true
    # end
    # end

    @props = { section: "Authorize", auth_id: history.auth_id }

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
