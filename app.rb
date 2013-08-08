require 'sinatra'
require 'json'
require './movies'

#
# Movies Global
#
movies = Movies.new

#
# Routes
#

#
# Documentation
#
get '/' do
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

end

#
# Error Handling
#
not_found do
  {:status => 404, :message => "Not Found"}.to_json
end

