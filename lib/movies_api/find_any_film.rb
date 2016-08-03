module MoviesApi
  # A source for fetching data from FindAnyFilm.com.
  class FindAnyFilm
    BASE_URL = "http://www.findanyfilm.com"

    attr_reader :agent

    def initialize
      @agent = Mechanize.new
    end

    # Find Cinemas using a given postcode.
    def find_cinemas(postcode)
      page = agent.get("#{BASE_URL}/find-cinema-tickets?" \
                       "townpostcode=#{postcode}")

      cinemas = []

      page.search(".cinemaResult").each do |result|
        cinema_id = result.attributes["rel"].value.scan(/[0-9]*/).join

        cinemas << Cinema.new(id: cinema_id, name: extract_cinema_name(result))
      end

      cinemas.each { |cinema| set_cinema_info(page, cinema) }
    end

    # Get the next showings for a Cinema.
    #
    # @param [String] cinema_id identifier for the cinema
    # @param [Date] date date to fetch showings for
    #
    # @return [Array] an array of `Showing` objects.
    #
    # rubocop:disable AbcSize, MethodLength
    def find_cinema_showings(cinema_id, date = Date.today)
      url = "#{BASE_URL}/api/screenings/venue_id/#{cinema_id}/date_from/#{date}"
      response = JSON.parse(Excon.get(url).body)

      showings = []

      response[cinema_id]["films"].each do |_k, v|
        film = film_from_json(v)

        v["showings"].each do |raw_showing|
          start_time = DateTime.parse(raw_showing["showtime"])

          if raw_showing["ticketing_link"] == '#no_link_available'
            booking_url = nil
          else
            booking_url = raw_showing["ticketing_link"]
          end

          showing = Showing.new(id: "#{cinema_id}_#{film.id}_" \
                                    "#{start_time.strftime('%Y%m%d%H%M%S')}",
                                cinema_id: cinema_id,
                                film_id: film.id,
                                film: film, # a hack
                                start_time: start_time,
                                booking_url: booking_url)

          showings << showing
        end
      end

      showings
    end
    # rubocop:enable AbcSize, MethodLength

    # Get the featured films listed on the site.
    def find_featured_films
      # 'http://www.findanyfilm.com/search/live-film?term=--TOP-INITIAL--'

      # %r{\([0-9]*\)}
    end

    private

    # Extract a clean name for a Cinema block.
    def extract_cinema_name(result)
      cinema_name = result.search(".cinemaName")
      cinema_name = cinema_name.first.children.to_s

      cinema_name.strip
    end

    # Extract a clean URL for a Cinema info block.
    def extract_cinema_url(result)
      url = result.search(".visitWebsiteLink a").first
      url.attributes["href"].value
    end

    # Extract an address block from a Cinema info block.
    def extract_address_block(result)
      # this is the only non addressable block, ironically.
      raw = result.search(".cinemaAddress").first.children.children.to_s

      raw = raw.gsub(%r{<strong>Address:<\/strong><br>}, "").strip
      address = ""
      raw.split("<br>").each do |component|
        address << "#{component.strip} "
      end

      address
    end

    # Set the info fields on a Cinema from a Mechanize::Page object.
    def set_cinema_info(page, cinema) # rubocop:disable MethodLength
      page.search("#cinemaInfo#{cinema.id}").each do |result|
        address_block = extract_address_block(result)

        address, phone = address_block.split(%r{<strong>Phone:<\/strong>})

        cinema.address = address.strip

        begin
          phone = phone.strip
          cinema.phone = phone
        rescue NoMethodError
          $stderr.puts "No phone number for: #{cinema.id}"
        end

        cinema.url = extract_cinema_url(result)
      end
    end

    # Build a `Film` object from JSON source.
    def film_from_json(json)
      film_data = json["film_data"]
      Film.new(id: film_data["film_id"],
               title: film_data["film_title"],
               release_year: film_data["release_year"],
               available_in_3d: film_data["has_3d_version"],
               certificate: film_data["certificate"])
    end
  end
end
