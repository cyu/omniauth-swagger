require 'sinatra'
require 'omniauth-swagger'
require 'pry'

# Callback URL will look like this: http://localhost:4567/auth/swagger/callback

# Store client_id as the login, secret as password
providers_config = YAML.load_file(File.join(File.dirname(__FILE__), "providers.yml"))
providers_config.keys.each do |key|
  providers_config[key][:uri] = File.join(File.dirname(__FILE__), "#{key}.json")
end

configure do
  enable :sessions

  use OmniAuth::Builder do
    providers_config = YAML.load_file(File.join(File.dirname(__FILE__), "providers.yml"))
    providers_config.keys.each do |key|
      providers_config[key][:uri] = File.join(File.dirname(__FILE__), "#{key}.json")
    end
    provider :swagger, providers: providers_config
  end
end

get '/' do
  links = providers_config.keys.map do |key|
    <<-HTML
      <li><a href="/auth/swagger?provider=#{key}">#{key}</a></li>
    HTML
  end
  <<-HTML
    <html>
    <body>
      <ol> #{links.join} </ol>
    </body>
    </html>
  HTML
end

get '/auth/:provider/callback' do
  auth = request.env['omniauth.auth']
  <<-HTML
    <html>
    <body>
      Provider: #{params['provider']}<br>
      UID: #{auth['uid']}<br>
      Token: #{auth['credentials']['token']}<br>
      Secret: #{auth['credentials']['token']}<br>
      Expires: #{auth['credentials']['expires']}<br>
      Expires At: #{auth['credentials']['expires_at']}<br>
      Raw Info:<br>
      <pre>
        #{auth["extra"]["raw_info"]}
      </pre>
    </body>
    </html>
  HTML
end
