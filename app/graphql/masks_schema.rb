# frozen_string_literal: true

class MasksSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  orphan_types Types::ClientType

  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    # if err.is_a?(GraphQL::InvalidNullError)
    #   # report to your bug tracker here
    #   return nil
    # end
    super
  end

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    case obj
    when Masks::Client
      Types::ClientType
    else
      raise(GraphQL::RequiredImplementationMissingError)
    end
  end

  # Limit the size of incoming queries:
  max_query_string_tokens(5000)

  # Stop validating when it encounters this many errors:
  validate_max_errors(100)

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    case object
    when Masks::Client
      client.to_gqlid
    end
  end

  # Given a string UUID, find the object
  def self.object_from_id(global_id, query_ctx)
    type, id = global_id.split(":")

    case type
    when "client"
      Masks::Client.find_by(key: id)
    end
  end
end