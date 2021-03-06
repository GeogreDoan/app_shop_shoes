class PaymentsController < ApplicationController
	def new
		if current_cart.cart_products.size == 0
	    	redirect_to '/', :notice => 'Your cart is empty'
	     	return
	    end
        @payment = Payment.new
	end

	def create
        if current_cart.cart_products.size == 0
            redirect_to '/', :notice => 'Your cart is empty'
            return
        else
    		@payment = Payment.new(payment_params)
            # address && km 
             if payment_params[:address] != nil  
                @location = Geocoder.search(payment_params[:address]).first.coordinates
                @ship = (Geocoder::Calculations.distance_between([10.80076,106.679557], @location.to_a)).ceil(1) # km 
                @place = Place.new
                @place.name = payment_params[:address]
                @place.latitude = @location[0]
                 @place.longitude = @location[1]
                @place.save
                @payment.place = @place
             end

            # Stripe.api_key = "sk_test_Hm0ywtd94a4e27SHOfzVJLpZ"
            @cart = current_cart
            @amount = @cart.total_price.to_i * 100
            token = params[:stripeToken]

              # Create a Customer
              customer = Stripe::Customer.create({
                :description => params[:name], 
                :card => token,
            })

              charge = Stripe::Charge.create({
                :customer => customer.id,
                :amount => @amount, # amount in cents, again
                :currency => 'usd',
                :description => params[:name],
              })
            if @payment.save
                @payment.add_line_items_from_cart(current_cart)
                Cart.destroy(session[:cart_id])
                session[:cart_id] = nil
                @payment.payment_items.each do |item|
                    @product = Product.find(item.product_id)
                    @product.quantity = @product.quantity - item.quantity
                    @product.save
                end
                redirect_to root_path
            else
                render 'new'
            end
        end
	end

    private
    def payment_params
      params.require(:payment).permit(:name, :phone, :address, :pay_type)
    end
end
