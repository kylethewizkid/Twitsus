require 'tweetstream'
class HomepageController < ApplicationController

  @@twitter_clients = []
  def index
    configure_tweet_stream()
    @@faye_client   = Faye::Client.new('http://fayebulous.herokuapp.com/faye')
    @currentSession = rand(36**9).to_s(36)
  end

  def kill_clients()
    kill_all_twitter_clients
    @@faye_client.disconnect    if @@faye_client.present?
    render :nothing => true
  end

  def change_bounds()
    if (params[:is_valid_zoom] == "true")
      bounds = {sw_lng: params[:sw_lng].to_f, 
                sw_lat: params[:sw_lat].to_f, 
                ne_lng: params[:ne_lng].to_f, 
                ne_lat: params[:ne_lat].to_f}
      locations = format_locations(bounds)
      kill_all_twitter_clients  
      start_twitter_client(locations, bounds, params[:currentSession])
    end
    render :nothing => true
  end

  private

  def kill_all_twitter_clients
    print @@twitter_clients.length
    until @@twitter_clients.empty? do
      @@twitter_clients.last.stop_stream
      @@twitter_clients.pop()
    end
  end

  def start_twitter_client(locations, bounds, currentSession)
    @@twitter_clients.push(TweetStream::Client.new)
    @@twitter_clients.last.filter({locations: locations}) do |status, client|
      @@tweeter = client
      tweet = Tweet.new(status, bounds)
      if (tweet.valid?)
        puts "#{tweet.text}\n#{locations}"
        @@faye_client.publish('/faye/' +  currentSession,
                              text:       tweet,
                              language:   tweet.language)
      end
    end
  end

  def format_locations(bounds)
    return "#{bounds[:sw_lng]},#{bounds[:sw_lat]},#{bounds[:ne_lng]},#{bounds[:ne_lat]}"
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