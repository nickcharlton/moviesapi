require 'sinatra'
require 'sinatra/param'
require 'json'
require './movies'

#
# Movies Global
#
movies = Movies.new

#
# Helpers
#
helpers Sinatra::Param

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
  param :page, Integer, default: 1

  # we'll always increment by 10 cinemas
  increment = 10
  # calculate the end from the page, then the start back from it
  end_count = params[:page] * increment
  start = (end_count - increment)
  # the first page makes for a bit of a special case
  # without this, the results will overhang each other
  if params[:page] > 1
    start += 1
  end

  range = Range.new(start, end_count)
  # fetch a specied range of cinemas
  cinemas = movies.find_cinemas_detailed(params[:postcode], range)

  # if we've tried to fetch too many, throw an exception
  unless cinemas[:cinemas].count > 0
    halt 400, {:message => 'The specified page parameter was out of range.'}.to_json
  end

  # set the link headers
  total = cinemas[:total]
  next_page_count = params[:page] + 1
  last_page_count = (total.to_f / increment.to_f).round
  
  next_page = url('/cinemas/find/%s?page=%d' % [params[:postcode], next_page_count])
  last_page = url('/cinemas/find/%s?page=%d' % [params[:postcode], last_page_count])

  # next isn't helpful unless we can progress
  if next_page_count > last_page_count
    link_set = "<#{last_page}>; rel='last'"
  else
    link_set = "<#{next_page}>; rel='next', <#{last_page}>; rel='last'"
  end

  headers 'Link' => link_set

  #  but, if it all worked, pass the data
  cinemas[:cinemas].to_json
end

#
# Show Listings for Cinemas
#
get '/cinemas/:venue_id/showings' do
  showings = movies.get_movie_showings(params[:venue_id], 1)

  showings.to_json
end

#
# Error Handling
#
not_found do
  {:status => 404, :message => "Not Found"}.to_json
end

