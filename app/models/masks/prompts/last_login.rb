module Masks
  module Prompts
    class LastLogin < Base
      around_auth prepend: true, always: true do |auth, block|
        approved = auth.approved?

        block.call

        auth.actor.touch(:last_login_at) if !approved && auth.approved?
      end
    end
  end
end
