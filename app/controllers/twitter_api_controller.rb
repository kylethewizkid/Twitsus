require 'tweetstream'
class TwitterApiController < ApplicationController


	KEYS = { 	consumer_key: 		'7lYgOweNHtppP6OkU2s3DXe4A',
				consumer_secret: 	'qm1Kt1WoDxqPP8MCfPgqY1geOEulmPaOB6GN9GbxgQWS6WbLQ6',
				oauth_token: 		'40685570-JHvUbJPn4rB789eKKZYjPl8qRNSk8qXDnr8ytpWpc',
				oauth_token_secret: 'rvpcG21ZD2oyI4wQe4Ca4CAO0a0rF4lWJwsThDSkaqfio' }

	def index
		EM::run {
			client = Faye::Client.new('http://fayebulous.herokuapp.com/faye')
			configure_tweet_stream()
			left_long = -122.75
			left_lat = 36.8
			right_long = -121.75
			right_lat = 37.8
			locations = format_locations(left_long, left_lat, right_long, right_lat)
			TweetStream::Client.new.filter({locations: locations}) do |status|  
				if ( is_tweet_inside_geo(left_long, left_lat, right_long, right_lat, status))
					puts "#{status.text}"
					language = tweet_language(status.text)
					if is_valid_language(language)
						client.publish('/faye/tweets', 'text' => status, 'language' => language[:name])
					end
				end

			end

		}
	end


	private 
	def is_valid_language(language)
		return language[:reliable] && language[:code] != "un" && language[:code] != 'xxx'
	end

	def is_tweet_inside_geo(left_long, left_lat, right_long, right_lat, status)
		return (left_long <= status.geo.lng.to_f && 
				left_lat <= status.geo.lat.to_f &&
				right_long >= status.geo.lng.to_f && 
				right_lat >= status.geo.lat.to_f)
	end

	def format_locations(left_long, left_lat, right_long, right_lat)
		return "#{left_long},#{left_lat},#{right_long},#{right_lat}"
	end

	def tweet_language(status)
		CLD.detect_language(status)
	end

	def configure_tweet_stream()
		TweetStream.configure do |config|
			config.consumer_key			= KEYS[:consumer_key]
			config.consumer_secret 		= KEYS[:consumer_secret]
			config.oauth_token 			= KEYS[:oauth_token]
			config.oauth_token_secret 	= KEYS[:oauth_token_secret]
			config.auth_method 			= :oauth
		end
	end
end