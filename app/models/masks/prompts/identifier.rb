module Masks
  module Prompts
    class Identifier
      include Masks::Prompt

      UPDATE_EVENT = "identify"

      match { true }

      before_entry do
        next if actor && identifier

        id =
          if event?(UPDATE_EVENT) && !checked?(Entry::FACTOR1)
            updates["identifier"]
          else
            session.bag(:entries)[:identifier]
          end

        session.bag(:entries)[:identifier] = id if id
        session.bag(:identifiers).current = id if id
        session.bag(:actors).current = Masks.identify(id) if id

        if actor&.new_record? && !actor&.valid?
          warn!("invalid-identifier", prompt: "identify")
        end
      end

      prompt "identify" do
        !identifier
      end
    end
  end
end
