module Masks
  module Authenticators
    class Base
      attr_reader :history

      cattr_accessor :events_map
      cattr_accessor :prompts_map

      delegate :request,
               :params,
               :session,
               :auth_session,
               :actor_session,
               :id_session,
               :client,
               :actor,
               :device,
               :login_link,
               :expired_time?,
               :authenticating?,
               :authenticated?,
               :authorized?,
               :password,
               :updates,
               :event?,
               :event,
               :path,
               :denied!,
               :authenticated!,
               :warn!,
               to: :history

      class << self
        def events(**events)
          self.events_map ||= {}
          self.events_map[name] ||= {}
          self.events_map[name].merge!(events)
        end

        def event(key, method = nil, &block)
          events(key => method || block) if method || block

          self.events_map&.dig(name, key.to_s)
        end

        def prompts(**opts)
          self.prompts_map ||= {}
          self.prompts_map[name] ||= {}
          self.prompts_map[name].merge!(opts)
        end

        def prompt(key, method = nil, &block)
          prompts(key => method || block) if method || block

          self.prompts_map&.dig(name, key.to_s)
        end
      end

      def initialize(history)
        @history = history
      end

      def prompt=(name)
        history.authenticator_prompt = name
      end

      def enabled?
        true
      end

      def prepare!
        prepare
      end

      def prompt
        history.authenticator_prompt
      end

      def prompt?
        history.authenticator_prompt
      end

      def authenticated?
        !authenticating? && !prompt?
      end

      def prompt!
        return if prompt?

        run_prompts
      end

      def event!(name)
        unless prompt?
          handle(self.class.event(name)) if name
        end
      end

      private

      def prepare
        nil
      end

      def run_prompts
        self.class.prompts.each do |name, handler|
          result = handle(handler)
          self.prompt = name if result
          break if result
        end
      end

      def handle(handler)
        case handler
        when Symbol
          send(handler)
        when Proc
          instance_exec(&handler)
        end
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
          warn! "invalid-email:#{updates["email"]}"
        end
      end

      def verify_code
        code = updates["code"]
        email =
          actor.emails.for_login.find_by(address: updates["email"]) if updates[
          "email"
        ]
        link = actor.login_links.active.for_verification.find_by(code:, email:)

        if code && !link
          warn! "invalid-code:#{code}"
        else
          link.verified!
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
          link = actor.login_links.build(history:, email:)
          link.save_and_deliver
        end
      end

      def second_factor!(type)
        second_factors[type] = client.expires_at(type)
      end

      def second_factors
        actor_session[:second_factors] ||= {}
      end

      def second_factor_valid?
        !second_factor_expired?
      end

      def second_factor_expired?
        return false if authenticating?
        return true if second_factors.keys.none?
        return true if !actor.second_factor?

        second_factors.values.all? { |time| expired_time?(time) }
      end
    end
  end
end
