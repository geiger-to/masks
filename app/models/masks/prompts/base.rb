module Masks
  module Prompts
    class Base
      attr_reader :auth

      cattr_accessor :prompt_map

      delegate :request,
               :params,
               :identifier,
               :identifier=,
               :client,
               :actor,
               :actor=,
               :device,
               :login_link,
               :login_link=,
               :authenticated?,
               :updates,
               :event?,
               :event,
               :path,
               :warn!,
               :prompt,
               :prompt=,
               :state,
               :rails_session,
               :install,
               to: :auth

      delegate :attempt_bag,
               :auth_bag,
               :actor_bag,
               :client_bag,
               :device_bag,
               :check,
               :checked!,
               :checked?,
               :checking?,
               to: :state

      class << self
        def prompt_config
          self.prompt_map ||= {}
          self.prompt_map[name] ||= {}
        end

        def events(**events)
          prompt_config[:events] ||= {}
          prompt_config[:events].merge!(events)
        end

        def event(key, method = nil, &block)
          events(key => method || block) if method || block
          prompt_config.dig(:events, key.to_s)
        end

        def prompts(**opts)
          prompt_config[:prompts] ||= {}
          prompt_config[:prompts].merge!(opts)
        end

        def prompt(key, method = nil, &block)
          prompts(key => method || block) if method || block
          prompt_config.dig(:prompts, key.to_s)
        end

        def checks(name = nil)
          prompt_config[:check] = name
        end

        def check
          prompt_config[:check]
        end

        def around_session(**args, &block)
          cls = self

          Masks::Auth.set_callback(:session, :around, **args) do |_, inner|
            next if (self.error || self.prompt) && !args[:always]
            prompt_for(cls).instance_exec(self, inner, &block)
          end
        end

        def before_session(**args, &block)
          cls = self

          Masks::Auth.set_callback(:session, :before, **args) do |_, &inner|
            next if (self.error || self.prompt) && !args[:always]
            prompt_for(cls).instance_exec(self, inner, &block)
          end
        end

        def after_session(**args, &block)
          cls = self

          Masks::Auth.set_callback(:session, :after, **args) do |_, &inner|
            next if (self.error || self.prompt) && !args[:always]
            prompt_for(cls).instance_exec(self, inner, &block)
          end
        end

        def around_auth(**args, &block)
          cls = self

          Masks::Auth.set_callback(:auth, :around, **args) do |_, inner|
            next if (self.error || self.prompt) && !args[:always]
            prompt_for(cls).instance_exec(self, inner, &block)
          end
        end

        def before_auth(**args, &block)
          cls = self

          Masks::Auth.set_callback(:auth, :before, **args) do |_, &inner|
            next if (self.error || self.prompt) && !args[:always]
            prompt_for(cls).instance_exec(self, inner, &block)
          end
        end

        def after_auth(**args, &block)
          cls = self

          Masks::Auth.set_callback(:auth, :after, **args) do |_, &inner|
            next if (self.error || self.prompt) && !args[:always]
            prompt_for(cls).instance_exec(self, inner, &block)
          end
        end
      end

      def initialize(auth)
        @auth = auth
      end

      def enabled?
        return true unless self.class.check

        !checked?(self.class.check)
      end

      def skip?
        return false unless self.class.check

        if checked?(self.class.check) || !checking?(self.class.check)
          true
        else
          false
        end
      end

      def prompt!
        run_prompts
      end

      def event!(name)
        handle(self.class.event(name)) unless prompt
      end

      def check
        return unless self.class.check

        state.check(self.class.check)
      end

      private

      def run_prompts
        self.class.prompts.each do |name, handler|
          break if self.prompt
          self.prompt ||= name if handle(handler)
        end
      end

      def handle(handler)
        return if !handler || skip?

        case handler
        when Symbol
          send(handler)
        when Proc
          instance_exec(&handler)
        end
      end

      def second_factor_enabled?
        (client&.check?("second-factor") || actor&.second_factor?)
      end

      def add_email
        email = actor.emails.build(address: updates["email"]) if updates[
          "email"
        ]
        email&.for_login

        if email&.save
          verify_email(email)
        else
          warn! "login-email-limit" if email&.too_many?
          warn! "invalid-email", updates["email"]
        end
      end

      def verify_code
        code = updates["code"]
        email =
          actor.emails.for_login.find_by(address: updates["email"]) if updates[
          "email"
        ]
        link = actor.login_links.active.for_verification.find_by(code:, email:)

        if code && link
          link.verified!
        else
          warn! "invalid-code", code

          false
        end
      end

      def reverify_email
        email =
          actor.emails.for_login.find_by(address: updates["email"]) if updates[
          "email"
        ]

        verify_email(email) if email
      end

      def verify_email(email)
        if email.login_links.active.for_verification.where(device: device).none?
          link = actor.login_links.build(auth:, email:)
          link.save_and_deliver
        end
      end
    end
  end
end
