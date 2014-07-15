require 'tweetstream'
class TwitterApiController < ApplicationController

  def index
    configure_tweet_stream()

    @@tweet_client  = TweetStream::Client.new
    @@faye_client   = Faye::Client.new('http://fayebulous.herokuapp.com/faye')
    @currentSession = rand(36**9).to_s(36)
    bounds = {}
    bounds[:left_long], bounds[:left_lat], bounds[:right_long], bounds[:right_lat] = create_bounds()
    @center = calculate_center(bounds)

    locations = format_locations(bounds)

    @@tweet_client.filter({locations: locations}) do |status|

      is_tweet_in_bounds  = tweet_in_bounds?(bounds, status)
      lang_of_tweet       = tweet_language(status.text)
      is_valid_language   = valid_language?(lang_of_tweet)

      if (is_tweet_in_bounds && is_valid_language )
        puts "#{status.text}"
        @@faye_client.publish('/faye/' +  @currentSession, 
                              text:       status, 
                              language:   lang_of_tweet[:name])
      end
    end
  end

  def kill_clients()
    @@tweet_client.stop_stream
    @@faye_client.disconnect
    render :nothing => true
  end

  private 
  def valid_language?(language)
    return language[:reliable] && language[:code] != "un" && language[:code] != 'xxx'
  end

  def tweet_in_bounds?(bounds, status)
    return (bounds[:left_long]   <= status.geo.lng.to_f && 
            bounds[:left_lat]    <= status.geo.lat.to_f &&
            bounds[:right_long]  >= status.geo.lng.to_f && 
            bounds[:right_lat]   >= status.geo.lat.to_f)
  end

  def format_locations(bounds)
    return "#{bounds[:left_long]},#{bounds[:left_lat]},#{bounds[:right_long]},#{bounds[:right_lat]}"
  end

  def tweet_language(status)
    CLD.detect_language(status)
  end

  def create_bounds()
    # Default to San Francisco bounds
    left_long = -122.75
    left_lat = 36.8
    right_long = -121.75
    right_lat = 37.8
    return [left_long, left_lat, right_long, right_lat]
  end

  def calculate_center(bounds)
    lat_center = (bounds[:left_lat]+bounds[:right_lat])/2
    long_center = (bounds[:right_long]+bounds[:right_lat])/2
    return {lat_center: lat_center, long_center: long_center}
  end

  def configure_tweet_stream()
    TweetStream.configure do |config|
      config.consumer_key       = ENV["CONSUMER_KEY"]
      config.consumer_secret    = ENV["CONSUMER_SECRET"]
      config.oauth_token        = ENV["OAUTH_TOKEN"]
      config.oauth_token_secret = ENV["OAUTH_TOKEN_SECRET"]
      config.auth_method        = :oauth
    end
  end
end