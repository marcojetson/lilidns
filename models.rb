require 'data_mapper'
require 'ipaddress'
require 'securerandom'

DataMapper::setup(:default, settings.database)

# pdns models

class Domain
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true, :length => 255, :unique_index => :name_index
  property :master, String, :length => 128
  property :last_check, Integer
  property :type, String, :required => true, :length => 6
  property :notified_serial, Integer
  property :account, String, :length => 40
end

class Record
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 255
  property :type, String, :length => 10, :default => 'A'
  property :content, String, :length => 65535
  property :ttl, Integer, :default => 60
  property :prio, Integer
  property :change_date, Integer
  property :disabled, Boolean, :required => true, :default => false
  property :ordername, String, :length => 255
  property :auth, Boolean, :required => true, :default => true

  belongs_to :domain, :required => false

  validates_with_method :check_host

  def check_host
    if not self.name =~ /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])$/
      [false, 'Host is not valid']
    elsif not IPAddress.valid? self.content
      [false, 'IP address is not valid']
    else
      true
    end
  end
end

class Supermaster
  include DataMapper::Resource
  property :ip, String, :required => true, :length => 64, :key => true, :unique_index => :ip_nameserver_pk
  property :nameserver, String, :required => true, :length => 255, :key => true, :unique_index => :ip_nameserver_pk
  property :account, String, :length => 40
end

class Comment
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true, :length => 255
  property :type, String, :length => 10
  property :modified_at, Integer, :required => true
  property :account, String, :length => 40
  property :comment, String, :required => true, :length => 65535

  belongs_to :domain
end

class DomainMetadata
  include DataMapper::Resource

  storage_names[:default] = 'domainmetadata'

  property :id, Serial
  property :kind, String, :length => 32
  property :content, String

  belongs_to :domain
end

class Cryptokey
  include DataMapper::Resource
  property :id, Serial
  property :flags, Integer, :required => true
  property :active, Boolean
  property :content, String

  belongs_to :domain
end

class Tsigkey
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true, :length => 255, :unique_index => :namealgoindex
  property :algorithm, String, :required => true, :length => 50, :unique_index => :namealgoindex
  property :secret, String, :required => true, :length => 255
end

# own

class RecordToken
  include DataMapper::Resource
  property :id, Serial
  property :token, String, :required => true, :length => 36, :default => lambda { |r, p| SecureRandom.uuid }

  belongs_to :record
end

DataMapper.finalize

Domain.auto_upgrade!
Record.auto_upgrade!
Supermaster.auto_upgrade!
Comment.auto_upgrade!
DomainMetadata.auto_upgrade!
Cryptokey.auto_upgrade!
Tsigkey.auto_upgrade!
RecordToken.auto_upgrade!

settings.domains.each do |domain|
  begin
    domain = Domain.new(:name => domain, :type => 'SOA')
    domain.save
  rescue DataObjects::IntegrityError
  end
end