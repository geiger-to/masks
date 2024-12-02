module Uploads
  class InstallationController < ManagersController
    def logo
      logo =
        case params[:theme]
        when "light"
          install.light_logo.attach(params[:file])
        when "dark"
          install.dark_logo.attach(params[:file])
        end

      if logo
        render json: { url: rails_storage_proxy_url(logo) }
      else
        render json: { url: nil }
      end
    end

    def favicon
      install.favicon.attach(params[:file])

      render json: { url: rails_storage_proxy_url(install.favicon) }
    end

    private

    def install
      Masks.installation.reload
    end
  end
end
