class LoginLinkMailer < ApplicationMailer
  def authenticate
    @link = params[:login_link]
    @client = @link.client
    @email = @link.email
    @actor = @link.actor

    mail(to: @email.address, subject: "Your login link to #{@client.name}...")
  end
end
