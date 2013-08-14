require File.expand_path 'spec_helper.rb', __dir__

describe 'Movies' do
  before do
    VCR.insert_cassette name

    @movies = Movies.new
  end

  after do
    VCR.eject_cassette
  end

  it 'fetches a list of cinemas' do
    cinemas = @movies.find_cinemas("PL15RH")
    
    # it should at least contain a cinema
    cinemas.wont_be_empty

    # pull out one and test that
    cinema = cinemas[0]
    cinema.must_be_kind_of Hash

    cinema['title'].wont_be_nil
    cinema['venue_id'].wont_be_nil
    cinema['distance'].wont_be_nil
  end

  it 'fetches the details of a cinema' do
    cinema = @movies.cinema_details("1552")

    # there should be some sort of result in the hash
    cinema['address'].wont_be_nil
    cinema['phone_number'].wont_be_nil
    cinema['link'].wont_be_nil
  end
end
