require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock

  # ensure codelimate still works
  c.ignore_hosts "codeclimate.com"
end
