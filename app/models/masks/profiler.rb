module Masks
  class Profiler < ApplicationModel
    attribute :profile
    attribute :request
    attribute :params

    def initialize(profile, request, params = {})
      super(profile:, request:, params:)
    end

    def key
      self.class.to_s.split('::').last.underscore
    end

    def param
      params[key]
    end

    def actor
      @actor ||= begin
        actor = find_actor unless @actor_searched
        @actor_searched = true
        actor
      end
    end

    def find_actor
      nil
    end

    def login
      nil
    end
  end
end
