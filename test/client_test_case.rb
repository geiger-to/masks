class ClientTestCase < MasksTestCase
  include AuthHelper

  class << self
    def test_client(**opts)
      auth_opts(**opts)

      prefix = "#{opts.slice(:path, :redirect_uri, :response_type).to_json}}"

      test "#{prefix} - manage client is returned" do
        authorize
        assert_client
        assert_artifacts(devices: 1)
      end

      test "#{prefix} - invalid response_types return an error" do
        if client.internal?
          skip "response_type cannot be overridden for internal clients"
        end

        authorize(response_type: "foobar")
        assert_error "invalid-response"
        assert_prompt "invalid-response"
        assert_settled
        assert_artifacts
      end

      test "#{prefix} - invalid redirect_uris return an error" do
        authorize(redirect_uri: "https://example.com/invalid")
        assert_error "invalid-redirect"
        assert_prompt "invalid-redirect"
        assert_artifacts
      end

      test "#{prefix} - empty redirect_uris accept the first supplied, when configured" do
        client.update(redirect_uris: nil, autofill_redirect_uri: true)
        authorize(redirect_uri: "https://example.com/invalid")
        refute_error
      end

      test "#{prefix} - empty redirect_uris save the first supplied, after authorization" do
        first = "https://example.com/first"
        client.update(redirect_uris: nil, autofill_redirect_uri: true)
        log_in("manager", redirect_uri: first, authorize: true)
        assert_equal(first, client.reload.redirect_uris)
      end

      test "#{prefix} - attempts expire after the allotted time" do
        client.update(auth_attempt_expires_in: "1 hour")

        freeze_time

        assert_login log_in("manager", authorize: true)

        travel_to client.expires_at(:auth_attempt) do
          assert_login attempt
        end

        travel_to client.expires_at(:auth_attempt) + 1.second do
          attempt

          assert_error "expired-state"
        end
      end

      test "#{prefix} - valid passwords expire after the configured time" do
        client.update(
          auth_attempt_expires_in: "1 hour",
          password_factor_expires_in: "2 hours",
        )
        freeze_time

        assert_login log_in("manager", authorize: true)

        # Travelling to this point expires the auth attempt, so an identifier
        # must be supplied again. However, the password check remains valid so
        # login is immediate.
        travel_to client.expires_at(:password_factor)

        authorize
        attempt_identifier "manager"
        attempt_authorize
        assert_login

        # The prior request settles the auth session for 1 hour. If we wait,
        # it expires, an identifier must be supplied again, and so too must
        # a password because it has now reached the timeout.
        travel_to 61.minutes.from_now
        authorize
        attempt_identifier "manager"
        attempt_authorize
        refute_settled
      end

      test "#{prefix} - invalid_credentials for invalid passwords" do
        log_in "manager", "invalid", authorize: true

        assert_warning "invalid-credentials"
        assert_prompt "credentials"
        assert_artifacts(devices: 1)
        refute_settled
      end

      test "#{prefix} - invalid_credentials for unknown actors" do
        log_in "invalid", "invalid", authorize: true

        assert_warning "invalid-credentials"
        assert_prompt "credentials"
        assert_artifacts(devices: 1)
        refute_settled
      end

      test "#{prefix} - rejects actors without required scopes" do
        client.update(scopes: { required: [SecureRandom.uuid] })

        log_in "tester"

        assert_prompt "missing-scopes"
        assert_error "missing-scopes"
        assert_artifacts(devices: 1)

        unless client.internal?
          assert_includes auth_result[:redirectUri], "invalid_request"
        end

        assert_not_includes auth_result[:redirectUri], "token"
        assert_not_includes auth_result[:redirectUri], "code"
      end
    end
  end
end
