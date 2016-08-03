$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "movies_api"

run MoviesApi::App
