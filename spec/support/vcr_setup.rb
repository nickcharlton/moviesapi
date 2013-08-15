require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'specs/cassettes'
  c.hook_into :fakeweb
end
