require 'sinatra'
require 'json'

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

