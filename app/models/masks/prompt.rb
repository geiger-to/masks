module Masks
  module Prompt
    extend ActiveSupport::Concern

    FIRST_FACTORS = %w[email password]
    SECOND_FACTORS = %w[webauthn otp phone]
    FIRST_OR_SECOND = FIRST_FACTORS + SECOND_FACTORS
    BACKUP_CODES = ["backup_codes"]
    FACTORS = FIRST_OR_SECOND + BACKUP_CODES

    included do
      cattr_accessor :prompt_map

      attr_reader :entry

      delegate :session,
               :extras,
               :path,
               :params,
               :event,
               :event?,
               :prompt,
               :prompt=,
               :checked!,
               :checked?,
               :trusted?,
               :extras,
               :warn!,
               :updates,
               to: :entry
    end

    class_methods do
      def prompt_config
        self.prompt_map ||= {}
        self.prompt_map[name] ||= {}
      end

      def events(**events)
        prompt_config[:events] ||= {}
        prompt_config[:events].merge!(events)
      end

      def event(key, method = nil, **args, &block)
        events(key => { handler: method || block, args: }) if method || block
        prompt_config.dig(:events, key.to_s)
      end

      def prompts(**opts)
        prompt_config[:prompts] ||= {}
        prompt_config[:prompts].merge!(opts)
      end

      def prompt(key, method = nil, **args, &block)
        prompts(key => { handler: method || block, args: }) if method || block
        prompt_config.dig(:prompts, key.to_s)
      end

      def match(method = nil, &block)
        prompt_config[:matchers] ||= []
        prompt_config[:matchers] << (method || block)
      end

      def prompt(key, method = nil, **args, &block)
        prompts(key => { handler: method || block, args: }) if method || block
        prompt_config.dig(:prompts, key.to_s)
      end

      def before_entry(**opts, &block)
        cls = self.to_s

        Masks::Entry.set_callback(:entry, :before, **opts) do |_, &inner|
          prompts[cls.to_s]._callback(inner, **opts, &block)
        end
      end

      def after_entry(**opts, &block)
        cls = self.to_s

        Masks::Entry.set_callback(:entry, :after, **opts) do |_, &inner|
          prompts[cls.to_s]._callback(inner, **opts, &block)
        end
      end

      def around_entry(**opts, &block)
        cls = self.to_s

        Masks::Entry.set_callback(:entry, :around, **opts) do |_, inner|
          prompts[cls.to_s]._callback(inner, **opts, &block)
        end
      end
    end

    def initialize(entry)
      @entry = entry
    end

    def request
      session.rails_request
    end

    def identifier
      session.current_identifier
    end

    def client
      session.current_client
    end

    def device
      session.current_device
    end

    def actor
      session.current_actor
    end

    def second_factor
      session.current_second_factor
    end

    def oauth_request
      session.current_oauth_request
    end

    def sibling(name)
      case name
      when Class
        entry.prompts.fetch(name.to_s)
      when String
        entry
          .prompts
          .fetch(name) { prompts.fetch("Masks::Prompts::#{name.classify}") }
      when Symbol
        entry.prompts.fetch("Masks::Prompts::#{name.to_s.classify}")
      else
        raise KeyError
      end
    end

    def prompt!
      self.class.prompts.each do |name, config|
        return if self.prompt

        self.prompt ||= name if handle(config)
      end
    end

    def event!
      handle(self.class.event(event)) unless prompt
    end

    def _callback(inner, **opts, &block)
      if handle?(opts)
        instance_exec(inner, &block)
      elsif inner
        inner.call
      end
    end

    private

    def handle(config)
      run_handler(config[:handler]) if config && handle?(config[:args] || {})
    end

    def handle?(options)
      return true if options[:always]
      return false if entry.prompt
      return false unless enabled?(options)

      matchers = self.class.prompt_config[:matchers] || []
      result = matchers.any? { |v| run_handler(v, args: [options]) }
    end

    def run_handler(handler, args: [])
      case handler
      when Symbol
        send(handler)
      when Proc
        instance_exec(*args, &handler)
      end
    end

    def enabled?(args)
      return false if args[:trusted] && !trusted?
      return false if args[:factors] && !verify_factor(*args[:factors])
      return false if args[:if] && !run_handler(args[:if])
      return false if args[:unless] && run_handler(args[:unless])

      true
    end

    def checked!(key, bag: :actors, **opts)
      session.bag(bag).expiring(
        key,
        opts,
        expiry:
          opts.delete(:expiry) ||
            client.expires_at("#{key.underscore}_#{opts[:with]}"),
      )

      true
    end

    def checked?(key, bag: :actors)
      !session.bag(bag).expired?(key)
    end

    def on_first_factor?
      !identifier || !checked?(Entry::FACTOR1)
    end

    def on_profile?
      trusted? && !checked?(Entry::FACTOR_PROFILE)
    end

    def on_2fa?
      checked?(Entry::FACTOR1) &&
        (
          client&.second_factor? || actor&.second_factor? ||
            actor.review_second_factor?
        )
    end

    def change_2fa?
      changeable_2fa? &&
        (!actor.second_factor? || verify_factor(*FIRST_OR_SECOND))
    end

    def changeable_2fa?
      on_2fa? || on_profile?
    end

    def verify_factor(*allowed)
      raise if allowed.empty?

      passed = false

      allowed.each do |key|
        raise unless FACTORS.include?(key.to_s)

        result = send("verify_#{key}")

        next if result.nil?

        passed = result

        break
      end

      warn! "invalid-factor" unless passed

      passed
    end

    def verify_email
      return unless client.allow_emails? && updates["email"]

      code = updates.dig("email", "code")
      link =
        actor.login_links.active.for_verification.find_by(
          code:,
          email: verified_email,
        )

      if link
        link.verified!

        true
      else
        warn! "invalid-code", code
      end
    end

    def verify_webauthn
      return unless client.allow_webauthn? && updates["webauthn"]

      webauthn = WebAuthn::Credential.from_get(updates["webauthn"])
      credential = actor&.hardware_keys&.find_by(external_id: webauthn.id)
      challenge = session.bag(:entries)["webauthn_challenge"]

      return warn! "invalid-webauthn" unless credential && challenge

      begin
        webauthn.verify(
          challenge,
          public_key: credential.public_key,
          sign_count: credential.sign_count,
        )

        credential.update!(
          sign_count: webauthn.sign_count,
          verified_at: Time.now.utc,
        )

        checked! Entry::FACTOR2, with: :webauthn
      rescue => e
        warn! "webauthn-error"
      end
    end

    def verify_phone
      return unless client.allow_phones? && updates["phone"]

      verify_phone_with_code(verified_phone, updates.dig("phone", "code"))
    end

    def verify_phone_with_code(phone, code)
      if phone.verify_code(code)
        checked! Entry::FACTOR2, with: :phone
      else
        warn! "invalid-code", code
      end
    end

    def verify_otp
      return unless client.allow_otp? && updates["otp"]

      otp_secret = verified_otp_secret
      otp_code = updates.dig("otp", "code")

      if otp_secret&.verify_otp(otp_code)
        checked! Entry::FACTOR2, with: :otp
      else
        warn! "invalid-code", otp_code
      end
    end

    def verify_otp_with_code(otp_secret, code)
      if otp_secret&.verify_otp(code)
        checked! Entry::FACTOR2, with: :otp
      else
        warn! "invalid-code", code
      end
    end

    def verify_backup_code
      return unless client.allow_backup_codes? && updates["backupCode"]

      if actor&.verify_backup_code(updates["backupCode"])
        checked! Entry::FACTOR2, with: :backup_code
      else
        warn! "invalid-code", updates["backupCode"]
      end
    end

    def verify_password
      return unless client.allow_passwords? && updates["password"]

      if actor&.authenticate(updates["password"])
        checked! Entry::FACTOR1, with: :password
        true
      else
        warn! "invalid-credentials"
        false
      end
    end

    def verified_phone
      @verified_phone ||=
        actor&.phones.find_by(number: updates.dig("phone", "number"))
    end

    def verified_email
      @verified_email ||=
        actor.emails.for_login.find_by(
          address: updates.dig("email", "address"),
        ) if updates["email"]
    end

    def verified_otp_secret
      @verified_otp_secret ||=
        actor.otp_secrets.find_by(
          public_id: updates.dig("otp", "id"),
        ) if updates["otp"]
    end
  end
end
