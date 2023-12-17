module Masks
  # @visibility private
  class OneTimeCodeController < ApplicationController
    require_mask type: :session, only: :new

    before_action only: %i[create destroy] do
      require_sudo(one_time_code_path)
    end

    def new
      respond_to { |format| format.html { render(:new) } }
    end

    def create
      if secret_param && code_param
        @actor.totp_secret = secret_param
        @actor.totp_code = code_param
        @actor.save if @actor.valid?

        flash[:errors] = @actor.errors.full_messages unless @actor.valid?
      end

      respond_to { |format| format.html { redirect_to one_time_code_path } }
    end

    def destroy
      @actor.totp_secret = nil
      @actor.save if @actor.valid?

      respond_to { |format| format.html { redirect_to one_time_code_path } }
    end

    private

    def create_params
      params.require(:one_time_code).permit(:code, :secret)
    end

    def code_param
      create_params[:code]
    end

    def secret_param
      create_params[:secret]
    end
  end
end
