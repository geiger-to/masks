module Masks
  # @visibility private
  class EmailsController < ApplicationController
    require_mask type: :session, only: :new
    before_action :require_sudo, only: :create

    def new
      @emails = current_actor.emails

      respond_to { |format| format.html { render(:new) } }
    end

    def create
      @email = current_actor.emails.build(email: email_param.strip)

      if @email.valid?
        @email.notify!(masked_session)
      else
        flash[:errors] = @email.errors.full_messages
      end

      respond_to { |format| format.html { redirect_to emails_path } }
    end

    def notify
      @email = current_actor.emails.find_by(email: email_param.strip)
      @email.notify!(masked_session) if @email.expired?

      respond_to { |format| format.html { redirect_to emails_path } }
    end

    def delete
      @email = current_actor.emails.find_by(email: email_param)
      @email.destroy if @email

      respond_to { |format| format.html { redirect_to emails_path } }
    end

    def verify
      @email = current_actor.emails.find_by(token: params[:email])
      @email&.verify! if @email&.valid?
    end

    private

    def email_param
      params.dig(:email, :value)
    end

    def require_sudo
      return if current_mask.type == "sudo" && passed?

      flash[:errors] = ["enter a valid password"]

      redirect_to emails_path
    end
  end
end
