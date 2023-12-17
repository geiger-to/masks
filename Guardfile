# frozen_string_literal: true

guard "shell" do
  watch(/^.+/) do |m|
    system("bundle exec yard doc") if File.extname(m[0]) == ".rb"
  end
end
