class Flight < ApplicationRecord
  def self.flysafair_routes
    {
      'JNB' => %w[DUR CPT BFN ELS PLZ MRU GRJ],
      'CPT' => %w[JNB ELS HLA DUR BFN GRJ PLZ],
      'DUR' => %w[JNB CPT ELS HLA BFN PLZ],
      'PLZ' => %w[JNB CPT DUR],
      'HLA' => %w[CPT DUR],
      'GRJ' => %w[JNB CPT BFN],
      'ELS' => %w[JNB CPT DUR],
      'BFN' => %w[JNB CPT DUR GRJ],
      'MRU' => %w[JNB]
    }.freeze
  end

  def self.create_return_flight_subscription(params, other_flight_id)
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
end
