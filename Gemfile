source 'https://rubygems.org' do
  gem "sinatra"
  gem "sinatra-activerecord"
  gem "sinatra-contrib"
  gem "sinatra-flash"
  gem "sendgrid-ruby"
  gem "activerecord"
  gem "rake"
  
  group :development do
  # our sqlite3 gem will only be used locally
  #   the sqlite3 gem is an adapter for sqlite
    gem "sqlite3"
  end

  group :production do
  # our pg gem will only be used on production
  #   the pg gem is an adapter for postgresql
    gem "pg"
  end

end