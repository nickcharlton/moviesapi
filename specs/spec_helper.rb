ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/pride'

# pull in the VCR setup
require File.expand_path './support/vcr_setup.rb', __dir__

# pull in the code to test
require File.expand_path '../movies.rb', __dir__
