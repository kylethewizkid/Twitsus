class Tweet
 	include ActiveModel::Model
	def self.initialize(status)
		@text = status;
	end
end