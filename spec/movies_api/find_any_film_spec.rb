require File.expand_path "../../spec_helper.rb", __FILE__

RSpec.describe MoviesApi::FindAnyFilm do
  let(:faf) { described_class.new }

  describe "find_cinemas" do
    it "returns cinemas from a postcode" do
      VCR.use_cassette("find_cinemas") do
        cinemas = faf.find_cinemas("N89BT")

        cinema = cinemas.first
        expect(cinema.id).to eq("7955")
        expect(cinema.name).to eq("ArtHouse Crouch End, London")
        expect(cinema.address).to eq("ArtHouse Crouch End, 159A " \
          "Tottenham Ln, London, N8 9BT")
        expect(cinema.phone).to eq("020 8245 3099")
        expect(cinema.url).to eq("http://arthousecrouchend.savoysystems.co.uk" \
          "/ArtHouseCrouchEnd.dll")
      end
    end
  end

  describe "find_cinema_showings" do
    it "returns showings for a cinema for today" do
      VCR.use_cassette("find_cinema_showings_for_today") do
        showings = faf.find_cinema_showings("7955")

        showing = showings.first
        expect(showing.id).to eq("7955_146186_20161114120000")
        expect(showing.cinema_id).to eq("7955")
        expect(showing.film_id).to eq("146186")
        expect(showing.start_time).to eq(DateTime.new(2016, 11, 14, 12, 0, 0))
        expect(showing.booking_url).to include("http://arthousecrouchend")

        film = showing.film
        expect(film.id).to eq("146186")
        expect(film.title).to eq("A Street Cat Named Bob")
        expect(film.release_year).to eq("2016")
        expect(film.available_in_3d).to eq("0")
        expect(film.certificate).to eq("12A")
      end
    end

    it "returns showings for a cinema for up to seven days" do
      VCR.use_cassette("find_cinema_showings_for_tomorrow") do
        showings = faf.find_cinema_showings("7955", Date.new(2016, 11, 14))

        showing = showings.first
        expect(showing.id).to eq("7955_146186_20161114120000")
        expect(showing.start_time).to eq(DateTime.new(2016, 11, 14, 12, 0, 0))
      end
    end
  end

  describe "find_featured_films" do
    it "returns the featured film from the homepage"
  end
end
