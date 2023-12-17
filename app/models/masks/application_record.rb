module Masks
  # Base model for +ActiveRecord+-backed database tables in masks.
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
