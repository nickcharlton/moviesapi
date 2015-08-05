module MoviesApi
  class Cinema < Resource
    attr_accessor :id, :name, :address, :phone, :url, :lat, :lon

    def to_json(_options)
      h = { venue_id: id, name: name, address: address, url: url, distance: '' }

      h.to_json
    end
  end
end
