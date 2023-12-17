module Masks
  class DeleteRecoveriesJob < ApplicationJob
    def perform
      Masks.configuration.model(:recovery).expired.destroy_all
    end
  end
end
