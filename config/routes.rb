RubyLLM::Monitoring::Engine.routes.draw do
  resources :alerts, only: :index
  resources :events, only: %i[index show]
  resources :metrics, only: :index

  root to: "metrics#index"
end
