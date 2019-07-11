# frozen_string_literal: true

require "rack-canonical-host"
$LOAD_PATH.push File.expand_path("lib", __dir__)
require "movies_api"

use Rack::CanonicalHost, ENV["CANONICAL_HOST"] if ENV["CANONICAL_HOST"]
run MoviesApi::App
