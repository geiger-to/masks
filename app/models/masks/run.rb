# frozen_string_literal: true
module Masks
  class Run < ApplicationModel
    attribute :profilers
    attribute :request
    attribute :params

    def profiled
      @profiled ||=
        profilers.to_h do |cls|
          profiler = cls.new(request, params)
          [profiler.key, profiler]
        end
    end

    def actors
      @actors ||=
        begin
          actors = []

          profiled.each_value do |profiler|
            actor = profiler.actor
            actors << actor if actor && !actors.include?(actor)
          end

          actors
        end
    end

    def actor
    end
  end
end
