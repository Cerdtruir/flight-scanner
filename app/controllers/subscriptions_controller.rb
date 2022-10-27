class SubscriptionsController < ApplicationController
  def new
    @subscription = Subscription.new
    @origins = Flight.flysafair_routes.keys
  end

  def create
    @subscription = Subscription.new(subscription_params)

    @subscription.lowest_price = Flight.where(date: @subscription.date_start..@subscription.date_end)
                                       .where(origin: @subscription.origin)
                                       .where(destination: @subscription.destination)
                                       .minimum(:price)

    render :new and return unless @subscription.save

    if params[:subscription][:return] == '1'
      params[:subscription][:date_start] = params[:subscription][:return_date_start]
      params[:subscription][:date_end] = params[:subscription][:return_date_end]
      return_flight = Flight.create_return_flight_subscription(subscription_params, @subscription.id)

      @subscription.update!(opposite_flight_id: return_flight.id)
    end

    redirect_to root_url, status: :see_other, notice: 'You are now subscribed!'
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email, :origin, :destination, :lowest_price, :date_start, :date_end,
                                         :opposite_flight_id)
  end
end
