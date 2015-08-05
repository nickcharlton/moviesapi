module MoviesApi
  class Showing < Resource
    attr_accessor :id, :cinema_id, :film_id, :start_time, :booking_url
  end
end
