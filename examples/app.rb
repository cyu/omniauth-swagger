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
        scope: 'user'
      },
      slack: {
        uri: File.join(File.dirname(__FILE__), 'slack.json'),
        client_id: n['slack'][0],
        client_secret: n['slack'][1],
        scope: 'identity'
      },
      stripe_connect: {
        uri: File.join(File.dirname(__FILE__), 'stripe_connect.json'),
        client_id: n['stripe_connect'][0],
        client_secret: n['stripe_connect'][1]
      }
    }
  end
end

get '/' do
  <<-HTML
    <html>
    <body>
      <ol>
        <li><a href="/auth/swagger?provider=github">Github</a></li>
        <li><a href="/auth/swagger?provider=slack">Slack</a></li>
        <li><a href="/auth/swagger?provider=stripe_connect">Stripe Connect</a></li>
      </ol>
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
      UID: #{auth['uid']}
    </body>
    </html>
  HTML
end
