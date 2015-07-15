set :views, "#{Dir.pwd}/views"
set :database, "sqlite3://#{Dir.pwd}/lilidns.db"

set :name, 'lilidns'
set :title, 'Free and simple dynamic DNS'

set :domains, ['lilidns.net']
set :ttl, 60