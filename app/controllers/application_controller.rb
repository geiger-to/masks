class ApplicationController < ActionController::Base
  helper_method :props_json

  private

  def props_json
    @props
      .deep_transform_keys do |key|
        key.to_s == "__typename" ? key : key.to_s.camelize(:lower)
      end
      .to_json
  end
end
