require 'sinatra'
require 'sinatra/flash'
require File.join(Dir.pwd, 'settings')
require File.join(Dir.pwd, 'models')

enable :sessions

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect to('/add')
end

get '/add' do
  @domains = Domain.all
  erb :add
end

post '/add' do
  begin
    record = Record.new(
      :name => params['subdomain'],
      :domain => Domain.get!(params['domain']), # DataMapper::ObjectNotFoundError
      :content => params['ip']
    )
    if record.save
      record_token = RecordToken.new(:record => record)
      record_token.save
      flash[:success] = 'Your host has been created'
      redirect to('/added/' + record_token.token)
    else
      @error = record.errors.first[0]
    end
  rescue DataMapper::ObjectNotFoundError
    @error = 'Something bad happened'
  end
  @domains = Domain.all
  erb :add
end

get '/added/:token' do
  erb :added
end

get '/update' do
  erb :update
end

post '/update' do
  record_token = RecordToken.first(:token => params['token'])
  if record_token
    record = record_token.record
    record.content = params['ip']
    if record.save
      flash[:success] = 'Your host has been updated.'
      redirect to('/update')
    else
      @error = 'Something happened'
    end
  else
    @error = 'Invalid token'
  end
  erb :update
end