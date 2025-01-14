# frozen_string_literal: true

module Mutations
  class Entry < BaseMutation
    input_object_class Types::EntryInputType

    field :entry, Types::EntryType, null: false

    def resolve(**args)
      entry = context[:entry]

      { entry: context[:entry] }
      # auth = context[:auth]
      # auth.update!(**args.merge(resume: context[:resume]))

      # result = auth.as_json
      # result[:request_id] = SecureRandom.uuid
      # result
    end
  end
end
