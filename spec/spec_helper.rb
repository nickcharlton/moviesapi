require "rack/test"
require "rspec"
require "pry"

require File.expand_path "./support/vcr_setup.rb", __dir__

require File.expand_path "../../lib/movies_api", __FILE__

ENV["RACK_ENV"] = "test"

module RSpecMixin
  include Rack::Test::Methods

  def app
    MoviesApi::App
  end
end

RSpec.configure { |c| c.include RSpecMixin }
