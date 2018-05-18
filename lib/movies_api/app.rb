# frozen_string_literal: true
module MoviesApi
  # Sinatra app to give basic film showing details.
  class App < Sinatra::Base
    use Raven::Rack

    helpers Sinatra::CustomLogger
    helpers Sinatra::Param

    configure :development, :production do
      logger = Timber::Logger.new(STDOUT)

      logger.level = Logger::DEBUG if development?
      set :logger, logger

      Timber::Integrations::Rack.middlewares.each do |middleware|
        use middleware
      end
    end

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
      faf = FindAnyFilm.new
      cinemas = faf.find_cinemas(params[:postcode])

      cinemas.to_json
    end

    #
    # Show Listings for Cinemas
    #
    get "/cinemas/:venue_id/showings/?:date?" do
      param :venue_id, String, required: true,
                               format: /^([0-9]*)$/,
                               message: "not a valid venue_id"

      faf = FindAnyFilm.new
      date = params[:date] || Date.today.strftime("%Y-%m-%d")
      showings = faf.find_cinema_showings(params[:venue_id], Date.parse(date))

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
