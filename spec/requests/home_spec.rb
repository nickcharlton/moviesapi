require File.expand_path "../../spec_helper.rb", __FILE__

RSpec.describe "home" do
  it "has a homepage" do
    get "/"

    expect(last_response).to be_ok
    expect(last_response.body).to include(
      "an API for movies and UK cinema listings",
    )
  end
end
