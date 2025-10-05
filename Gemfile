source "https://rubygems.org"

# Rails
gem "rails", "~> 8.0.3"

# The original asset pipeline for Rails
gem "sprockets-rails"

# Use PostgreSQL as the database for Active Record
gem "pg", ">= 1.1"

# Use the Puma web server
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps
gem "importmap-rails"

# Hotwire's SPA-like page accelerator
gem "turbo-rails"

# Hotwire's modest JavaScript framework
gem "stimulus-rails"

# Build JSON APIs with ease
gem "jbuilder"
gem 'activeadmin'
gem 'devise' 
# Gemfile
gem 'sassc-rails'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis
# gem "kredis"

# Use Active Model has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching
gem "bootsnap", require: false

# Use Active Storage variants
# gem "image_processing", "~> 1.2"

group :development, :test do
  # Debugging with the debug gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities
  gem "brakeman", require: false

  # Omakase Ruby styling
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages
  gem "web-console"
end

group :test do
  # Use system testing
  gem "capybara"
  gem "selenium-webdriver"
end
