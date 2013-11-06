require 'sinatra'
require 'json'
require './movies'

#
# Movies Global
#
movies = Movies.new

#
# Helpers
#
before do
  # we almost always want a JSON output
  content_type :json
end

#
# Routes
#

#
# Documentation
#
get '/' do
  # in this case, it shouldn't be JSON
  content_type :html

  erb :home
end

#
# Find Nearby Cinemas by Postcode
#
get '/cinemas/find/:postcode' do
  cinemas = movies.find_cinemas_detailed(params[:postcode])

  cinemas.to_json
end

#
# Show Listings for Cinemas
#
get '/cinemas/:venue_id/showings' do
  showings = movies.get_movie_showings(params[:venue_id], 0)

  showings.to_json
end

#
# Error Handling
#
not_found do
  {:status => 404, :message => "Not Found"}.to_json
end

