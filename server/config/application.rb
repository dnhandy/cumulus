require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Server
  class Application < Rails::Application
      config.load_defaults 5.1
      config.api_only = true
      if (ENV['RAILS_ENV'] == 'production')
        config.active_record.cache_timestamp_format = :nsec
      end
  end
end
