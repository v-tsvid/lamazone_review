class Customers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # @customer = Customer.from_omniauth(request.env["omniauth.auth"])
    @customer = OmniauthAuthorizer.new(request.env["omniauth.auth"]).authorize
    
    if @customer && @customer.save
      sign_in_and_redirect @customer, event: :authentication 
      set_flash_message(:notice, :success, 
                        kind: "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"] 
      redirect_to new_customer_registration_path
      set_flash_message(:notice, :failure, kind: "Facebook", 
        reason: "#{@customer.inspect}") if is_navigational_format?
    end
  end
end
