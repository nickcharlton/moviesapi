module MoviesApi
  class Cinema < Resource
    attr_accessor :id, :name, :address, :phone, :url, :lat, :lon
  end
end
