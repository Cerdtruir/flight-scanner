class SendEmailsJob < ApplicationJob
  queue_as :default

  def perform
    Subscription.all.each do |subscription|
      current_lowest_price_flight = Flight.where(date: subscription.date_start..subscription.date_end)
                                          .where(origin: subscription.origin)
                                          .where(destination: subscription.destination)
                                          .order(:price).first
      if subscription.lowest_price > current_lowest_price_flight.price
        subscription.update(lowest_price: current_lowest_price_flight.price)
        send_email(subscription.email, current_lowest_price_flight)
      end
    end
  end

  def send_email(email, flight)
    FlightMailer.with(flight:, email:).cheaper_flight_email.deliver_now
  end
end
