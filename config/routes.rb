RubyLLM::Monitoring::Engine.routes.draw do
  resources :alerts, only: :index
  resources :metrics, only: :index

  root to: "metrics#index"
end
