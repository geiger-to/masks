module AuthorizeTestCase
  extend ActiveSupport::Concern

  included do
    test "manage client is returned" do
      authorize
      assert_client
      assert_artifacts(devices: 1)
    end
  end
end
