class FlightsController < ApplicationController
  def index
    @origins = Flight.flysafair_routes.keys
    @destinations = Flight.flysafair_routes[params[:origin]] if params[:origin]

    start_date = params.fetch(:start_date, Date.today).to_date

    @flights = if params[:origin] && params[:destination]
                 Flight.where(origin: params[:origin], destination: params[:destination])
               else
                 Flight.all
               end

    @flights = @flights.where(date: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
  end
end
