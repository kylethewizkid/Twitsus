require 'tweetstream'
class TwitterApiController < ApplicationController

  def index
    configure_tweet_stream()

    @@tweet_client  = TweetStream::Client.new
    @@faye_client   = Faye::Client.new('http://fayebulous.herokuapp.com/faye')
    @currentSession = rand(36**9).to_s(36)

    left_long, left_lat, right_long, right_lat = generate_bounds()
    locations = format_locations(left_long, left_lat, right_long, right_lat)

    @@tweet_client.filter({locations: locations}) do |status|

      is_tweet_in_bounds  = tweet_in_bounds?(left_long, left_lat, right_long, right_lat, status)
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

  def tweet_in_bounds?(left_long, left_lat, right_long, right_lat, status)
    return (left_long   <= status.geo.lng.to_f && 
            left_lat    <= status.geo.lat.to_f &&
            right_long  >= status.geo.lng.to_f && 
            right_lat   >= status.geo.lat.to_f)
  end

  def format_locations(left_long, left_lat, right_long, right_lat)
    return "#{left_long},#{left_lat},#{right_long},#{right_lat}"
  end

  def tweet_language(status)
    CLD.detect_language(status)
  end

  def generate_bounds()
    # Default to San Francisco bounds
    left_long = -122.75
    left_lat = 36.8
    right_long = -121.75
    right_lat = 37.8
    return [left_long, left_lat, right_long, right_lat]
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