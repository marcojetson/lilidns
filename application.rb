require 'json'
require 'pony'
require 'sinatra'
require 'sinatra/flash'
require 'sinatra/subdomain'
require File.join(File.dirname(__FILE__), 'settings')
require File.join(File.dirname(__FILE__), 'assets')
require File.join(File.dirname(__FILE__), 'helpers')
require File.join(File.dirname(__FILE__), 'models')

environment = File.join(File.dirname(__FILE__), 'environment')
if File.exists?(environment + '.rb')
  require environment
end

enable :sessions

subdomain :api do
  post '/update' do
    content_type :json
    begin
      record_token = RecordToken.first(:token => env['HTTP_AUTHORIZATION']) or raise ArgumentError, 'Can not find host'
      record = record_token.record
      record.content = params['ip'] || request.ip 
      record.save_host
      @error = false
    rescue ArgumentError => e
      @error = e.message
    rescue
      @error = 'Something bad happened'
    end
    {:error => @error}.to_json
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
    record.save_host
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

post '/sendmail' do
  Pony.mail :to => params[:email], :from => settings.email, :subject => 'Your update token', :body => 'Your update token is ' + h(params['token']) + ', keep it safe.'
  flash[:success] = 'Email sent'
  redirect to('/added/' + params['token'])
end

get '/update' do
  erb :update
end

post '/update' do
  begin
    record_token = RecordToken.first(:token => params['token']) or raise ArgumentError, 'Can not find host'
    record = record_token.record
    record.content = params['ip']
    record.save_host
    flash[:success] = 'Your host has been updated.'
    redirect to('/update')
  rescue ArgumentError => e
    @error = e.message
  rescue
    @error = 'Something bad happened'
  end
  erb :update
end