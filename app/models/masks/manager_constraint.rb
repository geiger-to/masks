module Masks
  class ManagerConstraint
    def matches?(request)
      session =
        Masks::InternalSession.from_request(
          request:,
          client: Masks::Client.manage,
        )
      session.masks_manager?
    end
  end
end
