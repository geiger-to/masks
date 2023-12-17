module Masks
  # @visibility private
  class KeysController < ApplicationController
    require_mask type: :session

    def new
      @keys = current_actor.keys
    end

    def create
      key =
        current_actor.keys.build(
          name: create_params[:name],
          secret: create_params[:secret]&.presence,
          scopes: create_params[:scopes]
        )
      key.save

      if key.valid?
        flash[:key] = { name: key.name, secret: key.secret }
      else
        flash[:error] = key.errors.full_messages.first
      end

      redirect_back_or_to keys_path
    end

    def delete
      key = current_actor.keys.find(params[:id])
      key.destroy

      flash[:notice] = "#{key.name} destroyed" if key.destroyed?

      redirect_back_or_to "/"
    end

    private

    def create_params
      params.require(:key).permit(:name, :secret, scopes: [])
    end
  end
end
