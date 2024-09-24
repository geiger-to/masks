class ApplicationModel
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON
end
