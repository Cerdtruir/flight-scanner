class SubscriptionsController < ApplicationController
  def new
    @subscription = Subscription.new
    @origins = Flight.flysafair_routes.keys
  end

  def create
    params[:subscription][:date_start] = params[:subscription][:date_start].to_date
    params[:subscription][:date_end] = params[:subscription][:date_end].to_date

    params[:subscription][:lowest_price] = Flight.where(date: params[:subscription][:date_start].to_date..params[:subscription][:date_end].to_date)
                                                 .where(origin: params[:subscription][:origin])
                                                 .where(destination: params[:subscription][:destination])
                                                 .minimum(:price)

    @subscription = Subscription.new(subscription_params)
    if @subscription.save
      if params[:subscription][:return] == '1'
        return_flight = create_return_flight_subscription(subscription_params, @subscription.id)
        @subscription.update!(opposite_flight_id: return_flight.id)
      end

      redirect_to root_url, notice: 'You are now subscribed!'
    else
      render :new
    end
  end

  private

  def create_return_flight_subscription(params, other_flight_id)
    return_flight = Subscription.new(params)
    return_flight.opposite_flight_id = other_flight_id
    return_flight.origin = params[:destination]
    return_flight.destination = params[:origin]
    return_flight.lowest_price = Flight.where(date: return_flight.date_start..return_flight.date_end)
                                       .where(origin: return_flight.origin)
                                       .where(destination: return_flight.destination)
                                       .minimum(:price)
    return_flight.save
    return_flight
  end

  def subscription_params
    params.require(:subscription).permit(:email, :origin, :destination, :lowest_price, :date_start, :date_end,
                                         :opposite_flight_id)
  end
end
