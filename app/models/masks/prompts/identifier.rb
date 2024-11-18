module Masks
  module Prompts
    class Identifier < Base
      before_auth do
        identifier =
          (
            if event?("identifier:add")
              updates["identifier"]
            else
              attempt_bag[:identifier]
            end
          )
        actor = Masks.identify(identifier) if identifier

        self.identifier = identifier
        self.actor = actor
      end

      def enabled?
        !attempt_bag&.dig(:identifier) || checking?("credentials")
      end

      prompt "identify" do
        if actor&.new_record? && !actor&.valid?
          self.identifier = nil

          warn!("invalid-identifier")
        end

        !identifier
      end

      event "identifier:add" do
        attempt_bag[:identifier] = updates["identifier"] if updates[
          "identifier"
        ]
      end
    end
  end
end
