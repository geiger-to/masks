module Masks
  module Prompts
    class Identifier < Base
      before_auth do
        identifier =
          (
            if event?("identify")
              updates["identifier"]
            else
              attempt_bag["identifier"]
            end
          )
        actor = Masks.identify(identifier) if identifier

        self.identifier = identifier
        self.actor = actor

        if actor&.new_record? && !actor&.valid?
          self.identifier = nil

          warn!("invalid-identifier", prompt: "identify")
        end
      end

      def enabled?
        !attempt_bag&.dig("identifier") || checking?("credentials")
      end

      prompt "identify" do
        !identifier
      end

      event "identify" do
        attempt_bag["identifier"] = updates["identifier"] if updates[
          "identifier"
        ]
      end
    end
  end
end
