require 'open-uri'

class MeteorologistController < ApplicationController
  def street_to_weather_form
    # Nothing to do here.
    render("street_to_weather_form.html.erb")
  end

  def street_to_weather
    @street_address = params[:user_street_address]
    url_safe_street_address = URI.encode(@street_address)

    # ==========================================================================
    # Your code goes below.
    # The street address the user input is in the string @street_address.
    # A URL-safe version of the street address, with spaces and other illegal
    #   characters removed, is in the string url_safe_street_address.
    # ==========================================================================

    # get lat & long data
    loc_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address}"
    parsed_loc_data = JSON.parse(open(loc_url).read)
      latitude = parsed_loc_data["results"][0]["geometry"]["location"]["lat"]
      longitude = parsed_loc_data["results"][0]["geometry"]["location"]["lng"]

    # set up forecast data
    forecast_url = "https://api.forecast.io/forecast/17593b21cc409b60b31ec90b6a5d8d38/#{latitude},#{longitude}"
    parsed_forecast_data = JSON.parse(open(forecast_url).read)

    # define new address variable using google's clean address for output to page
    @clean_street_address = parsed_loc_data["results"][0]["formatted_address"]

    #### assign weather data to variables ####
    @current_temperature = parsed_forecast_data["currently"]["temperature"]

    @current_summary = parsed_forecast_data["currently"]["summary"]

    # flag for minutely==nilclass because dark sky forecast doesn't return minutely information for all locations
    parsed_forecast_data["minutely"].nil? ?
        @summary_of_next_sixty_minutes = "No information available." :
        @summary_of_next_sixty_minutes = parsed_forecast_data["minutely"]["summary"]

    @summary_of_next_several_hours = parsed_forecast_data["hourly"]["summary"]

    @summary_of_next_several_days = parsed_forecast_data["daily"]["summary"]

    render("street_to_weather.html.erb")
  end
end
