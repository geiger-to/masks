class EmailVerificationMailer < ApplicationMailer
  def verify
    @email = params[:email]
    @actor = @email.actor

    mail(
      to: @email.address,
      subject: "Your verification code from #{@email.otp_issuer}",
    )
  end
end
