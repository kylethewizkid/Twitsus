class Tweet
 	include ActiveModel::Model
  include ActiveModel::Validations

  validate :validate_language, :validate_tweet_bounds
  attr_accessor :text, :language, :bounds, :lat, :lng
	def initialize(status, bounds)
		@text = status.text;
    @language = tweet_language(@text)
    @bounds = bounds
    @lat = status.geo.lat.to_f
    @lng = status.geo.lng.to_f
	end

  def tweet_language(text)
    CLD.detect_language(text)
  end

  def validate_language()
    unless language[:reliable] && language[:code] != "un" && language[:code] != 'xxx'
      errors.add(:language, "must be known & reliable")
    end
  end

  def validate_tweet_bounds()
    unless (bounds[:sw_lng] <= lng && 
            bounds[:sw_lat] <= lat &&
            bounds[:ne_lng] >= lng && 
            bounds[:ne_lat] >= lat)
      errors.add(:bounds, "must encapsulate tweet")
    end
  end
end