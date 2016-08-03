# frozen_string_literal: true
source "https://rubygems.org"

ruby "2.3.1"

# sinatra and friends
gem "sinatra", "~> 1.4"
gem "sinatra-param", "~> 1.4"

# requests
gem "mechanize", "~> 2.7"
gem "excon", "~> 0.45"

# tasks
gem "rake", "~> 11.2"

# error handling
gem "sentry-raven", "~> 1.2"

group :development, :test do
  gem "minitest", "~> 5.7"
  gem "webmock", "~> 2.1"
  gem "vcr", "~> 3.0"
  gem "codeclimate-test-reporter", require: nil
end
