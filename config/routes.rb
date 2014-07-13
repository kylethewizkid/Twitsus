Rails.application.routes.draw do
  root 'twitter_api#index'
  get 'get_tweets', to: 'twitter_api#get_tweets'
  match 'twitter_api/kill_em' => 'twitter_api#kill_em', :via => [:post]
end