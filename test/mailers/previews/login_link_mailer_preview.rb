# Preview all emails at http://localhost:3000/rails/mailers/login_link_mailer
class LoginLinkMailerPreview < ActionMailer::Preview
  def authenticate
    LoginLinkMailer.with(login_link: Masks::LoginLink.first).authenticate
  end
end
