class ShippingAddressForm < Reform::Form
  extend ::ActiveModel::Callbacks
  include AddressModule

  define_model_callbacks :save
  before_save :normalize_phone
  
  def save
    run_callbacks :save do
      super
    end
  end
end