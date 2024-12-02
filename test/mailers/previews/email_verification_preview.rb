# Preview all emails at http://localhost:3000/rails/mailers/login_link_mailer
class EmailVerificationPreview < ActionMailer::Preview
  def verify
    EmailVerificationMailer.with(
      email: Masks::Email.unverified_for_login.first,
    ).verify
  end
end
