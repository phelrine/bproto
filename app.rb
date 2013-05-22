require 'sinatra/base'
require 'oauth'
require 'model'
require 'mongoid'
require 'uri'

CONSUMER_KEY = '9ShqDRUTNfLz5w=='
CONSUMER_SECRET = 'yNFFQolvRycYDJfGKkVmabBP7oM='

class App < Sinatra::Base
  configure do
    use Rack::Session::Cookie, :secret => CONSUMER_SECRET
    set :logging, true
    set :dump_errors, true
    set :show_exceptions, true
    Mongoid.load!("mongoid.yml")
  end

  helpers do
    def login?
      return unless session[:username]
      return unless @user = User.find_by_name(session[:username])
      @user
    end

    def authorize_required?(url)
      url =~ /auth/
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end

    def url_encode(url)
      URI.encode(url)
    end
  end

  before do
    if authorize_required? request.url
      halt 'login required' if not login?
    end
  end

  get '/' do
    erb :index
  end

  post '/login' do
    return unless params[:username]
    user = User.find_by_name(params[:username])
    user = User.create(username: params[:username]) unless user
    session[:username] = user.username
    redirect '/'
  end

  post '/logout' do
    session.delete(:username)
    redirect '/'
  end

  get '/auth/recommend' do
    type = params[:type]
    return unless type
    case type
    when "friend"
      return @user.friend_filtering
    when "content"
      return @user.collaborative_filtering
    end
  end

  post '/auth/bookmark' do
    halt unless params[:url]
    @user.bookmark(params[:url])
    # erb :bookmark, layout: false, locals: {bookmark: @user.bookmark(params[:url])}
    redirect '/'
  end

  post '/auth/unbookmark' do
    halt unless params[:bookmark_id]
    bookmark = Bookmark.where(id: params[:bookmark_id]).first
    bookmark.destroy

  end

  post '/auth/follow' do
    halt unless params[:user]
    friend = User.where(params[:user]).first
    @user.follow(friend)
  end
end
