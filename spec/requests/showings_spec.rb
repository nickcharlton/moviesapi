require File.expand_path "../../spec_helper.rb", __FILE__

RSpec.describe "Showings" do
  let(:json) { JSON.parse(last_response.body) }

  describe "GET /cinemas/:venue_id/showings" do
    it "returns showings for a cinema" do
      VCR.use_cassette("request_showings") do
        Timecop.freeze(2016, 11, 14) do
          get "/cinemas/7955/showings"

          expect(json[0]["title"]).to eq("A Street Cat Named Bob")
          expect(json[0]["time"]).to eq(["12:00", "17:30"])
        end
      end
    end

    it "returns showings for a cinema for a date" do
      VCR.use_cassette("request_showings_for_date") do
        get "/cinemas/7955/showings/2016-11-17"

        expect(json[0]["title"]).to eq("Nocturnal Animals")
        expect(json[0]["time"]).to eq(["12:20", "17:45"])
      end
    end

    it "responds with a client error if a date is not valid" do
      get "/cinemas/7955/showings/1"

      expect(last_response).to be_bad_request
      expect(json["message"]).to eq("not a valid date format")
    end

    it "validates the venue is an integer" do
      get "/cinemas/$7955/showings"

      expect(last_response).to be_bad_request
      expect(json["message"]).to eq("not a valid venue_id")
    end
  end
end
