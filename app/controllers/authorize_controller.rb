class AuthorizeController < ApplicationController
  include Masks::InternalController
  include FrontendController

  rescue_from Masks::MissingClientError do
    render_error status: 404, prompt: "missing-client"
  end

  def new
    entry = Masks::Entries::Authorization.new(session: masks_session, params:)

    frontend_props(**entry.to_gql)

    headers["X-Masks-Entry-Id"] = entry.id

    status = entry.error ? 400 : 200

    respond_to do |format|
      format.html { render "app", status: }
      format.json { render json:, status: }
    end
  end
end
