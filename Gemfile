source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.2", ">= 7.2.2.1"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Redis adapter to run Action Cable in production
 # gem "redis", ">= 4.0.1"
gem 'ckeditor'
# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem 'redis'
gem 'redis-rails'
gem 'omniauth'
gem 'figaro'
gem 'sidekiq'
gem 'wicked_pdf'

 # gem 'wkhtmltopdf-binary'
gem 'pundit'
gem "bootstrap"
gem "sassc-rails"
gem 'sass' # Replace with a newer version, e.g., '~> 3.7.5' or higher
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
gem 'seed_dump'
gem 'sass-rails', '~> 5.0'
gem 'postmark-rails'
gem 'simple_form_fancy_uploads'
# Use Active Storage variant
gem 'image_processing', '~> 1.2'
gem 'dotenv-rails'
gem 'carrierwave', '~> 3.0'
gem "mini_magick"
gem "fog-aws"
gem 'arctic_admin'
gem 'kaminari'
gem 'trix'
#gem 'mini_racer', platforms: :ruby
gem 'devise'
gem 'activeadmin_quill_editor'
gem 'httparty'
gem "simple_form"
gem 'friendly_id'
# gem 'jquery-rails'
gem 'sitemap_generator'
gem 'activeadmin', '3.2.5'
gem 'toastr-rails'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Highlight the fine-grained location where an error occurred [https://github.com/ruby/error_highlight]
  gem "error_highlight", ">= 0.4.0", platforms: [ :ruby ]
end
group :production do
  gem 'redis'
  gem 'redis-rails'
  gem 'sidekiq'
  gem 'sidekiq-failures', '~> 1.0' # Optional for failure tracking

  gem 'rails_12factor' # Helps with logging on Heroku
end
group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
