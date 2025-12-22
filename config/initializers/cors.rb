# config/initializers/cors.rb
# ref: https://github.com/cyu/rack-cors

# font cors issue with CDN
# Ref: https://stackoverflow.com/questions/56960709/rails-font-cors-policy

ALLOWED_ORIGINS = [
  'https://chatwoot.studio.datachain.ai',
  'https://studio.datachain.ai',
  'https://studio.dvc.dev'
]

if Rails.env.development?
  ALLOWED_ORIGINS << 'http://localhost:3000'
end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins *ALLOWED_ORIGINS
    resource '/packs/*', headers: :any, methods: [:get, :options]
    resource '/audio/*', headers: :any, methods: [:get, :options]
    # Make the public endpoints accessible to the frontend
    resource '/public/api/*', headers: :any, methods: :any

    if ActiveModel::Type::Boolean.new.cast(ENV.fetch('CW_API_ONLY_SERVER', false)) || Rails.env.development?
      resource '*', headers: :any, methods: :any, expose: %w[access-token client uid expiry]
    end

    if ActiveModel::Type::Boolean.new.cast(ENV.fetch('ENABLE_API_CORS', false))
      resource '/api/*', headers: :any, methods: :any, expose: %w[access-token client uid expiry]
    end
  end
end

class AdditionalSecurityHeaders
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    headers['cross-origin-embedder-policy'] = 'credentialless'
    headers['cross-origin-resource-policy'] = 'cross-origin'
    headers['content-security-policy'] = "frame-ancestors 'self' #{ALLOWED_ORIGINS.join(' ')};"

    [status, headers, response]
  end
end

Rails.application.config.middleware.insert_before Rack::Cors, AdditionalSecurityHeaders

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
