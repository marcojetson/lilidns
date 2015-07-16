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
    domain = Domain.get!(params['domain'])
    record = Record.new(
      :name => params['subdomain'] + '.' + domain.name,
      :domain => domain,
      :content => params['ip'],
      :ttl => settings.ttl,
      :type => 'A'
    )
    record.save
    record_token = RecordToken.new(:record => record)
    record_token.save
    flash[:success] = 'Your host has been created'
    redirect to('/added/' + record_token.token)
  rescue DataMapper::ObjectNotFoundError
    @error = 'Something bad happened'
  rescue ArgumentError => e
    @error = e.message
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
  begin
    record_token = RecordToken.first(:token => params['token']) or raise ArgumentError, 'Can not find host'
    record = record_token.record
    record.content = params['ip']
    record.save
    flash[:success] = 'Your host has been updated.'
    redirect to('/update')
  rescue ArgumentError => e
    @error = e.message
  rescue
    @error = 'Something bad happened'
  end
  erb :update
end