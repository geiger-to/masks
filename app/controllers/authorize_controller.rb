class AuthorizeController < ApplicationController
  include FrontendController
  include AuthController

  def new
    gql =
      MasksSchema.execute(
        Masks.authenticate_gql,
        variables: {
          input: {
          },
        },
        context: {
          auth:,
        },
      )

    auth = gql.as_json.dig("data", "authenticate").with_indifferent_access

    headers["X-Masks-Auth-Id"] = auth[:id] unless auth[:error]

    status =
      case auth[:error]
      when nil
        200
      else
        400
      end

    props(section: "Authorize", auth:)

    respond_to do |format|
      format.html { render "app", status: }
      format.json { render json: auth, status: }
    end
  end

  private

  def client
    @client ||=
      (Masks::Client.find_by(key: params[:client_id]) if params[:client_id])
  end
end
