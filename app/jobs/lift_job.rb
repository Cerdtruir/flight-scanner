class LiftJob < ApplicationJob
  queue_as :default

  def perform
    routes = {
      'CPT' => %w[JNB],
      'JNB' => %w[CPT DUR],
      'DUR' => %w[JNB]
    }

    selected_month = Date.today.month
    selected_year = Date.today.year

    routes.each do |origin, destinations|
      destinations.each do |destination|
        pull_route_flights(origin, destination, selected_month, selected_year)
      end
    end
  end

  def request(url)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['authority'] = 'www.lift.co.za'
    request['accept'] = '*/*'
    request['accept-language'] = 'en-GB,en;q=0.6'
    request['dnt'] = '1'
    request['referer'] = 'https://www.lift.co.za/'
    request['sec-fetch-dest'] = 'empty'
    request['sec-fetch-mode'] = 'cors'
    request['sec-fetch-site'] = 'same-origin'
    request['sec-gpc'] = '1'
    request['user-agent'] =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36'
    request['Cookie'] =
      'incap_ses_1023_2435458=9oYRa+ncxjLD1pe/3G0yDtm6TmMAAAAApytdO8R2QSIKIhnUiFrb7g==; nlbi_2435458=PTC2eATBGj1NMZ8lxbuPIwAAAAAM2CW4eW0ptQEZtKxJ22SN; visid_incap_2435458=JfewUW+7ScmGPxgPOxw2ts66TmMAAAAAQUIPAAAAAADlprqmnAiNFHUbGmG03UtQ; AWSALB=Kx0I89WErhjj/xzN0I7uFoB0tyC8vfYWVOIGL29cR0qn+upwtDZmgmTMBELWMLq9BnEQ10KgoXsJiGE2MFP/ElbVlizLw9vW4QkdG47K0UTHjWOinWsmZ90gtSVC; AWSALBCORS=Kx0I89WErhjj/xzN0I7uFoB0tyC8vfYWVOIGL29cR0qn+upwtDZmgmTMBELWMLq9BnEQ10KgoXsJiGE2MFP/ElbVlizLw9vW4QkdG47K0UTHjWOinWsmZ90gtSVC; PHPSESSID=29e856qd59gdett0q5gju0lbi3; rgisanonymous=true; rguserid=7339f409-812a-45aa-9336-aa43982b6cf2; rguuid=true'

    https.request(request)
  end

  def pull_route_flights(origin, destination, selected_month, selected_year)
    12.times do
      url = URI("https://www.lift.co.za/controllers/bookingProcess/searchCalendar.php?type=RT&adults=1&children=0&infants=0&fromDst=#{origin}&toDst=#{destination}&startDate=#{selected_year}/#{selected_month}/01")
      response = request(url)
      data = JSON.parse(response.read_body)
      data['calendar'].first['days'].each do |day|
        add_data(day, origin, destination, selected_month, selected_year)
      end

      if selected_month == 12
        selected_month = 1
        selected_year += 1
      elsif selected_month < 12
        selected_month += 1
      end
      sleep 1
    end
  end

  def add_data(data, origin, destination, selected_month, selected_year)
    day_number = data['daynumber'].to_i
    price = data['fare']
    return unless price

    if (flight = Flight.where(origin:, destination:,
                              date: Date.new(selected_year, selected_month, day_number)).first)
      flight.update(price:, airline: 'Lift') if flight.price > price || flight.airline == 'Lift'
    else
      Flight.create!(origin:, destination:, date: Date.new(selected_year, selected_month, day_number),
                     price:, airline: 'Lift')
    end
  end
end
