# frozen_string_literal: true
module MoviesApi
  # Sinatra app to give basic film showing details.
  class App < Sinatra::Base
    POSTCODE_REGEX = /^([A-Za-z][A-Ha-hJ-Yj-y]?[0-9][A-Za-z0-9]? ?[0-9][A-Za-z]{2}|[Gg][Ii][Rr] ?0[Aa]{2})$/

    use Raven::Rack

    helpers Sinatra::CustomLogger
    helpers Sinatra::Param

    before do
      # we almost always want a JSON output
      content_type :json
    end

    #
    # Documentation
    #
    get "/" do
      # in this case, it shouldn't be JSON
      content_type :html

      erb :home
    end

    #
    # Find Nearby Cinemas by Postcode
    #
    get "/cinemas/find/:postcode" do
      param :postcode, String, format: POSTCODE_REGEX,
                               message: "must be a full, valid UK postcode"

      faf = FindAnyFilm.new
      cinemas = faf.find_cinemas(params[:postcode])

      cinemas.to_json
    end

    #
    # Show Listings for Cinemas
    #
    get "/cinemas/:venue_id/showings/?:date?" do
      halt 500,
           { message: "This endpoint is currently broken as " \
              "Find Any Film has changed." }.to_json

      param :venue_id, String, required: true,
                               format: /^([0-9]*)$/,
                               message: "not a valid venue_id"
      param :date, Date, required: false,
                         default: Date.today.strftime("%Y-%m-%d"),
                         message: "not a valid date format"

      faf = FindAnyFilm.new
      showings = faf.find_cinema_showings(params[:venue_id], params[:date])

      # this is technically showing films, not showings
      # so, we're, badly, flipping it back to the original implementation
      films = {}

      showings.each do |showing|
        film = films.fetch(showing.film.title, {})

        film[:title] = showing.film.title
        film[:link] = ""
        times = film.fetch(:time, [])
        times << showing.start_time.strftime("%H:%M")
        film[:time] = times

        films[film[:title]] = film
      end

      response = []
      films.each { |_k, v| response << v }

      response.to_json
    end

    #
    # Error Handling
    #
    not_found do
      { status: 404, message: "Not Found" }.to_json
    end
  end
end
