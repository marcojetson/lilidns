set :views, "#{File.dirname(__FILE__)}/views"
set :database, "sqlite3://#{File.dirname(__FILE__)}/lilidns.db"

set :name, 'lilidns'
set :title, 'Free and simple dynamic DNS'
set :email, 'noreply@lilidns.com'

set :domains, ['lilidns.net']
set :ttl, 60
set :nameservers, ['ns1.lilidns.com', 'ns2.lilidns.com']