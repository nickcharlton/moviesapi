require File.expand_path "../../spec_helper.rb", __FILE__

RSpec.describe "Cinemas" do
  let(:json) { JSON.parse(last_response.body) }

  describe "GET /cinemas/find/:postcode" do
    it "returns cinemas around a given postcode" do
      VCR.use_cassette("request_cinemas") do
        get "/cinemas/find/N89BT"

        expect(last_response).to be_ok
        expect(json[0]["venue_id"]).to eq("7955")
        expect(json[0]["name"]).to eq("ArtHouse Crouch End, London")
        expect(json[0]["address"]).to eq("ArtHouse Crouch End, 159A " \
          "Tottenham Ln, London, N8 9BT")
        expect(json[0]["url"]).to eq("http://arthousecrouchend.savoysystems" \
          ".co.uk/ArtHouseCrouchEnd.dll")
      end
    end
  end
end
