# config/initializers/cross_origin.rb
# ref: https://github.com/cyu/rack-cors

# font cors issue with CDN
# ref: https://stackoverflow.com/questions/56960709/rails-font-cors-policy
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://studio.datachain.ai', 'https://chatwoot.studio.datachain.ai', `https://studio.dvc.dev'
    resource '/packs/*', headers: :any, methods: [:get, :options]
    resource '/audio/*', headers: :any, methods: [:get, :options]
    # Make the public endpoints accessible to the frontend
    resource '/public/api/*', headers: :any, methods: :any

    if ActiveModel::Type::Boolean.new.cast(ENV.fetch('CW_API_ONLY_SERVER', false)) || Rails.env.development?
      resource '*', headers: :any, methods: :any, expose: %w[access-token client uid expiry]
    end
  end
end

class CrossOriginPolicies
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    headers['cross-origin-embedder-policy'] = 'credentialless'
    headers['cross-origin-resource-policy'] = 'cross-origin'
    headers['content-security-policy'] = "frame-ancestors 'self' https://studio.datachain.ai;"

    [status, headers, response]
  end
end

Rails.application.config.middleware.insert_before 0, CrossOriginPolicies

################################################
######### Action Cable Related Config ##########
################################################

# Mount Action Cable outside main process or domain
# Rails.application.config.action_cable.mount_path = nil
# Rails.application.config.action_cable.url = 'wss://example.com/cable'
# Rails.application.config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

# To Enable connecting to the API channel public APIs
# ref : https://medium.com/@emikaijuin/connecting-to-action-cable-without-rails-d39a8aaa52d5
Rails.application.config.action_cable.disable_request_forgery_protection = true
