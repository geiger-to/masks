class AuthorizeController < AuthorizedController
  include HistoryHelper

  def new
    history.start!

    @props = { section: "Authorize", auth: history_json }

    unless history.error
      @props[:auth_id] = history.auth_id

      headers["X-Masks-Auth-Id"] = history.auth_id
    end

    status =
      case history.error
      when nil
        200
      else
        400
      end

    respond_to { |format| format.html { render "app", status: } }
  end

  private

  def client
    @client ||=
      (Masks::Client.find_by(key: params[:client_id]) if params[:client_id])
  end
end
