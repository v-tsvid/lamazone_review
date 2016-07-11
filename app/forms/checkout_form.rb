class CheckoutForm < Reform::Form
  extend ::ActiveModel::Callbacks
  include PriceCalculator

  NEXT_STEPS = [:address, :shipment, :payment, :confirm, :complete]

  model :order
  
  define_model_callbacks :validation

  before_validation :update_shipping_price
  before_validation :update_subtotal
  before_validation :update_total_price
  
  property :total_price
  property :completed_date
  property :state
  property :customer
  property :next_step
  property :shipping_method
  property :shipping_price
  property :subtotal

  collection :order_items, populate_if_empty: OrderItem, form: OrderItemForm
  property :billing_address, populate_if_empty: Address, form: BillingAddressForm 
  property :shipping_address, populate_if_empty: Address, form: ShippingAddressForm
  property :credit_card, populate_if_empty: CreditCard, form: CreditCardForm
  property :coupon, populate_if_empty: Coupon, form: CouponForm
  

  validates :subtotal,
            :total_price, 
            :customer,  
            :state, 
            :next_step, 
            presence: true
  
  validates(:subtotal, :total_price, numericality: { greater_than: 0 }, 
    unless: :next_step_address?)

  validates(:credit_card, presence: true, 
    if: :next_step_confirm_or_complete?)

  validates(:billing_address, :shipping_address, presence: true, 
    unless: :next_step_address?)

  validates(:shipping_method, inclusion: { in: SHIPPING_METHOD_LIST },
    unless: :next_step_address_or_shipment?)
  validates(:shipping_price, numericality: { greater_than_or_equal: 0 },
    unless: :next_step_address_or_shipment?)

  validates :order_items, presence: true
  validates :state, inclusion: { in: Order::STATE_LIST }
  
  # provided by validates_timeliness gem
  # validates value as a date
  validates :completed_date, timeliness: {type: :date}, allow_blank: true
  

  def persisted?
    false
  end

  def save
    super
    model.save!
  end

  def valid?
    run_callbacks :validation do
      super
    end
  end

  def init_empty_attributes(step)
    init_addresses if step == :address
    init_credit_card if step == :payment
  end
  
  private

    def init_addresses
      self.model.billing_address ||= self.model.customer.billing_address
      self.model.shipping_address ||= self.model.customer.shipping_address
    end

    def init_credit_card
      self.model.credit_card ||= CreditCard.new
    end

    def next_step_confirm_or_complete?
      self.next_step == 'confirm' || self.next_step == 'complete'
    end

    def next_step_address_or_shipment?
      next_step_address? || next_step_shipment?
    end

    def next_step_address?
      self.next_step == 'address'
    end

    def next_step_shipment?
      self.next_step == 'shipment'
    end
end