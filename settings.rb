set :views, "#{Dir.pwd}/views"
set :database, "sqlite3://#{Dir.pwd}/lilidns.db"

set :name, 'lilidns'
set :title, 'Free and simple dynamic DNS'
set :email, 'noreply@lilidns.com'

set :domains, ['lilidns.net']
set :ttl, 60
set :nameservers, ['ns1.lilidns.com', 'ns2.lilidns.com']