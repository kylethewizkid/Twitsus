Rails.application.routes.draw do
  root 'twitter_api#index'
  get 'get_tweets', to: 'twitter_api#get_tweets'
end