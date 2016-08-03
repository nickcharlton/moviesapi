# frozen_string_literal: true
require File.expand_path "spec_helper.rb", __dir__

describe "Movies" do
  before do
    VCR.insert_cassette name

    @movies = Movies.new
  end

  after do
    VCR.eject_cassette
  end

  it "fetches a list of cinemas" do
    cinemas = @movies.find_cinemas("PL15RH")
    
    # it should at least contain a cinema
    cinemas.wont_be_empty

    # pull out one and test that
    cinema = cinemas[0]
    cinema.must_be_kind_of Hash

    cinema["title"].wont_be_nil
    cinema["venue_id"].wont_be_nil
    cinema["distance"].wont_be_nil
  end

  it "fetches the details of a cinema" do
    cinema = @movies.cinema_details("1552")

    # there should be some sort of result in the hash
    cinema["address"].wont_be_nil
    cinema["phone_number"].wont_be_nil
    cinema["link"].wont_be_nil
  end

  it "has a version featuring full cinema details" do
    cinemas = @movies.find_cinemas_detailed("PL15RH")

    # the initial data structure is a Hash describing the response
    cinemas.must_be_kind_of Hash
    cinemas[:cinemas].wont_be_empty
    cinemas[:total].must_be :>, 0

    # pull out one and test that
    cinema = cinemas[:cinemas][0]
    cinema.must_be_kind_of Hash

    # it has a combination of the details in the other set
    cinema["title"].wont_be_nil
    cinema["venue_id"].wont_be_nil
    cinema["distance"].wont_be_nil
    cinema["address"].wont_be_nil
    cinema["phone_number"].wont_be_nil
    cinema["link"].wont_be_nil
  end

  it "gets showings for a cinema" do
    showings = @movies.get_movie_showings("1552", "0")

    # it should be a list of showings
    showings.must_be_kind_of Array

    # if there are some, it should be a bit like this
    if not showings.empty?
      showing = showings[0]
      showing.must_be_kind_of Hash

      showing["title"].wont_be_nil
      showing["link"].wont_be_nil
      showing["time"].must_be_kind_of Array
    else
      showings.must_be_empty
    end
  end
end
