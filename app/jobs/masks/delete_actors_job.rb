module Masks
  class DeleteActorsJob < ApplicationJob
    def perform
      Masks.configuration.expire_actors
    end
  end
end
