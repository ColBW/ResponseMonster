source 'https://rubygems.org'

gem 'rails', '3.2.8'
gem 'haml'
gem 'bcrypt-ruby'
gem 'jquery-rails'
gem 'lazy_high_charts'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development, :test do
  gem 'sqlite3'
  gem 'debugger'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'capybara', '1.1.2'
  gem 'rb-inotify' if RUBY_PLATFORM.downcase.include?("linux")
  gem 'rb-fsevent' if RUBY_PLATFORM.downcase.include?("darwin")
  gem 'terminal-notifier-guard' if RUBY_PLATFORM.downcase.include?("darwin")
  gem 'libnotify', '0.5.9'
  gem 'travis-lint' 
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'libv8'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails'
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
