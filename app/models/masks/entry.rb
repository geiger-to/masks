module Masks
  class Entry
    include ActiveSupport::Callbacks

    FACTOR1 = "first-factor"
    FACTOR2 = "second-factor"
    FACTOR_PROFILE = "profile"

    class << self
      def prompt!(*args, **opts)
        new(*args, **opts).tap { |e| e.prompt! }
      end
    end

    define_callbacks :entry

    attr_reader :session, :raw_params

    attr_writer :prompt

    attr_accessor :event
    attr_accessor :scopes
    attr_accessor :error

    def initialize(session:, params:)
      @session = session
      @raw_params = params

      enter!
    end

    def id
      session_key
    end

    def path
      session.rails_request.path
    end

    def params
      raise NotImplementedError
    end

    def client
      raise NotImplementedError
    end

    def install
      @install ||= Masks.installation
    end

    def settings
      install.public_settings
    end

    def actor
      session.current_actor
    end

    def login_link
      session.current_login_link
    end

    def event?(name)
      event && event.to_s == name.to_s
    end

    def updates
      {}
    end

    def settled?
    end

    def stages
      client.second_factor? ? [FACTOR1, FACTOR2] : [FACTOR1]
    end

    def trusted?
      stages.all? { |s| checked?(s) }
    end

    def redirect_uri
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

    def prompt!(value)
      @prompt = value.to_s unless prompt
    end

    def warnings
      @warnings ||= []
    end

    def warn!(*keys, prompt: nil)
      warnings << keys.compact.join(":")
      @warnings.uniq!

      self.prompt = prompt if prompt
    end

    def extras(**additions)
      @extras ||= {}
      @extras.deep_merge!(additions)
      @extras
    end

    def session_key
      "#{client.key}:#{Digest::SHA256.hexdigest(params.to_query)}"
    end

    def session_lifetime
      nil
    end

    def enter!
      raise AuthError unless prompts.any?

      session.bag :entries, parent: :devices, current: self

      raise MissingClientError unless client

      session.bag :clients, parent: :devices, current: client
      session.bag :actors, parent: :devices
      session.bag :identifiers, parent: :devices
      session.bag :credentials, parent: :devices
      session.bag :second_factors, parent: :devices
      session.bag :login_links, parent: :devices
      session.bag :login_link_emails,
                  parent: :entries,
                  expiry: client.expires_at(:login_link)
      session.bag :single_sign_ons, parent: :entries

      run_callbacks(:entry) do
        enter
      rescue AuthError => e
        settled!(prompt: e.code, error: e.code)
      end

      self
    end

    def prompt
      error || @prompt
    end

    def prompts
      @prompts ||=
        Masks.env.prompts.map { |cls| [cls.to_s, cls.new(self)] }.to_h
    end

    def to_gql
      # Check out this amazing hack...
      @gql ||=
        begin
          json =
            MasksSchema.execute(
              Masks.authenticate_gql,
              variables: {
                input: {
                },
              },
              context: {
                entry: self,
                serialize: true,
              },
            ).as_json

          data = json.dig("data", "authenticate")

          raise AuthError unless data

          data
        end
    end

    private

    def oauth_request
      @oauth_request ||=
        Masks::Shims::OAuthRequest.call(client, params) do |oauth|
          session.bag(:oauth_requests, current: oauth)
          run_prompts
        end
    end

    def run_prompts
      return if prompt || @prompted || settled?

      @prompted = true

      instances = prompts.values
      instances.each(&:event!) if event
      instances.each(&:prompt!) unless prompt
    end

    def enter
      raise NotImplementedError
    end
  end
end
