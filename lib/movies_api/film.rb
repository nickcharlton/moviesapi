# frozen_string_literal: true
module MoviesApi
  class Film < Resource
    attr_accessor :id, :title, :release_year, :available_in_3d, :certificate
  end
end
