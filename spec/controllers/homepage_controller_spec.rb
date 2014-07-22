require 'rails_helper'
describe HomepageController do
  describe "kill_clients" do
    it "Should not render anything" do
      @@tweet_client  = TweetStream::Client.new
      @@faye_client   = Faye::Client.new('http://fayebulous.herokuapp.com/faye')
      get :kill_clients
      expect(response).to_not render_template(layout: "application")
    end
  end

  describe "valid_language?" do
    it "Should not recognize xxx as a valid language" do
      language = {reliable: true, code: "xxx"}
      expect(controller.send(:valid_language?, language)).to eql(false)
    end

    it "Should not recognize un as a valid language" do
      language = {reliable: true, code: "un"}
      expect(controller.send(:valid_language?, language)).to eql(false)
    end

    it "Should not recoqnize unreliable languages as valid" do
      language = {reliable: false, code: "en"}
      expect(controller.send(:valid_language?, language)).to eql(false)
    end

    it "Should recognize a valid language" do
      language = {reliable: true, code: "en"}
      expect(controller.send(:valid_language?, language)).to eql(true)
    end
  end

  describe "format_locations" do
    bounds = {sw_lng: 0, sw_lat: 2, ne_lng: 5.453454, ne_lat: 4}
    it "Should output a boundary string" do
      expected = "0,2,5.453454,4"
      expect(controller.send(:format_locations, bounds)).to eql(expected)
    end
  end

  describe "tweet_language" do
    tweet = "Hello, my name is Kyle"
    it "Should return a hash" do
      expect(controller.send(:tweet_language, tweet)).to be_a(Hash)
    end
    it "Should have a reliable tag" do
      expect(controller.send(:tweet_language, tweet)[:reliable]).to_not be_nil
    end
    it "Should have a name tag (set to english in this case)" do
      expect(controller.send(:tweet_language, tweet)[:name]).to eql("ENGLISH")
    end
  end

  describe "create_bounds" do
    bounds = {sw_lng: -122.75, sw_lat: 36.8, ne_lng: -121.75, ne_lat: 37.8}
    it "Should return an array" do
      expect(controller.send(:create_bounds)).to be_a(Array)
    end
    it "The first output should be the sw_lng" do
      expect(controller.send(:create_bounds)[0]).to eql(bounds[:sw_lng])
    end
    it "The second output should be the sw_lat" do
      expect(controller.send(:create_bounds)[1]).to eql(bounds[:sw_lat])
    end
    it "The third output should be the ne_lng" do
      expect(controller.send(:create_bounds)[2]).to eql(bounds[:ne_lng])
    end
    it "The fourth output should be the ne_lat" do
      expect(controller.send(:create_bounds)[3]).to eql(bounds[:ne_lat])
    end
  end

  describe "calculate_center" do
    bounds = {sw_lng: 0, sw_lat: 0, ne_lng: 1, ne_lat: 1}
    it "Should return the coordinates of the center of the coordinate box." do
      expect(controller.send(:calculate_center, bounds)).to eql({lat_center: 0.5, long_center: 0.5})
    end
  end
end