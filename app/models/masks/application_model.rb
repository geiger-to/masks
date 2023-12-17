# frozen_string_literal: true

module Masks
  # Base model for synthetic +ActiveRecord+-style models in masks.
  #
  # Most models in masks use this in their inheritance tree, as it
  # provides attributes, validations, and other features from
  # +ActiveModel+.
  class ApplicationModel
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Attributes
    include ActiveModel::Serializers::JSON
  end
end
