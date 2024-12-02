module Uploads
  class ClientController < ManagersController
    def create
      client = Masks::Client.find_by!(key: params[:client_id])
      client.logo.attach(params[:file])

      render json: { url: rails_storage_proxy_url(client.logo) }
    end
  end
end
