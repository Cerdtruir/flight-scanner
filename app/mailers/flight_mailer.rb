class FlightMailer < ApplicationMailer
  def cheaper_flight_email
    @flight = params[:flight]
    @email = params[:email]
    mail(to: @email, subject: "Cheaper flight found! #{@flight.origin} to #{@flight.destination}")
  end
end
