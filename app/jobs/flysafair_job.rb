class FlysafairJob < ApplicationJob
  queue_as :default

  def perform
    routes.each do |origin, destinations|
      destinations.each do |destination|
        get_flights(origin, destination)
      end
    end
  end

  def routes
    {
      'JNB' => %w[DUR CPT BFN ELS PLZ MRU GRJ HDS KIM LVI LUN BUQ HRE VFA SEZ],
      'CPT' => %w[JNB ELS HLA DUR BFN GRJ PLZ HDS],
      'DUR' => %w[JNB CPT ELS HLA BFN PLZ],
      'PLZ' => %w[JNB CPT DUR],
      'HLA' => %w[CPT DUR],
      'GRJ' => %w[JNB CPT BFN],
      'ELS' => %w[JNB CPT DUR],
      'BFN' => %w[JNB CPT DUR GRJ],
      'MRU' => %w[JNB],
      'VFA' => %w[JNB],
      'HRE' => %w[JNB],
      'BUQ' => %w[JNB],
      'HDS' => %w[JNB CPT],
      'LUN' => %w[JNB],
      'LVI' => %w[JNB],
      'KIM' => %w[JNB],
      'SEZ' => %w[JNB]
    }.freeze
  end

  def get_flights(origin, destination)
    selected_month = Date.today.month
    selected_year = Date.today.year

    while selected_month != Date.today.month + 1 && selected_year != Date.today.year + 1
      response = request(origin, destination, selected_month, selected_year)
      data = JSON.parse(response.read_body)
      add_data(data, origin, destination, selected_month, selected_year)

      selected_month += 1 if selected_month < 12

      if selected_month == 12
        selected_month = 1
        selected_year += 1
      end
    end
  end

  def request(origin, destination, month, year)
    url = URI('https://www.flysafair.co.za/LowFareRequest/GetMonthResult')

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['authority'] = 'www.flysafair.co.za'
    request['accept'] = '*/*'
    request['accept-language'] = 'en-GB,en;q=0.8'
    request['content-type'] = 'application/json'
    request['dnt'] = '1'
    request['origin'] = 'https://www.flysafair.co.za'
    request['referer'] = 'https://www.flysafair.co.za/cheap-flights/low-fare-search?Origin=JNB&Destination=CPT&Departure=2023-03-01&Return=2023-03-01&SearchOnPageLoad=True&Adults=1&Children=0&Infants=0&Promocode='
    request['sec-fetch-dest'] = 'empty'
    request['sec-fetch-mode'] = 'cors'
    request['sec-fetch-site'] = 'same-origin'
    request['sec-gpc'] = '1'
    request['user-agent'] =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36'
    request['x-requested-with'] = 'XMLHttpRequest'
    request.body = JSON.dump({
                               "origin": origin,
                               "destination": destination,
                               "departureYear": year,
                               "departureMonth": month,
                               "currency": 'ZAR',
                               "adults": '1',
                               "children": 0,
                               "infants": 0,
                               "promocode": '',
                               "urlReferrer": ''
                             })
    https.request(request)
  end

  def add_data(data, origin, destination, selected_month, selected_year)
    data['WeekResults'].each do |week|
      week['DayResults'].each do |day|
        next if day['LowestPrice'].nil?

        day_number = day['DayNumber']
        price = day['LowestPrice']

        if (flight = Flight.where(origin:, destination:,
                                  date: Date.new(selected_year, selected_month, day_number)).first)
          flight.update(price:, airline: 'FlySaFair')
        else
          Flight.create!(origin:, destination:, date: Date.new(selected_year, selected_month, day_number),
                         price:, airline: 'FlySaFair')
        end
      end
    end
  end
end