require 'sinatra'
require 'omniauth-swagger'
require 'pry'
require 'netrc'

# Store client_id as the login, secret as password
n = Netrc.read(File.join(File.dirname(__FILE__), 'providers.netrc'))

configure do
  enable :sessions

  use OmniAuth::Builder do
    provider :swagger, providers: {
      github: {
        uri: File.join(File.dirname(__FILE__), 'github.json'),
        client_id: n['github'][0],
        client_secret: n['github'][1],
        scope: 'user',
        uid: "get_user#id"
      }
    }
  end
end

get '/auth' do
  redirect to('/auth/swagger?provider=github')
end

get '/auth/:provider/callback' do
  auth = request.env['omniauth.auth']
  <<-HTML
    <html>
    <body>
      Provider: #{params['provider']}<br>
      UID: #{auth['uid']}
    </body>
    </html>
  HTML
end
