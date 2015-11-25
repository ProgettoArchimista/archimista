require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    # Upgrade 2.0.0 inizio
    config.time_zone = 'Rome'
    # Upgrade 2.0.0 fine

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # Upgrade 2.0.0 inizio
    rails_root_wrk=File.expand_path('../..', __FILE__)

    config.i18n.load_path += Dir[File.join(rails_root_wrk, 'config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :it
    # Upgrade 2.0.0 fine

    # Upgrade 2.0.0 inizio
    customizations_path = Dir[File.join(rails_root_wrk, "lib", "*.rb")].reject do |path|
      path =~ /.*\/tasks.*/
    end
    Dir.glob(customizations_path).each do |filepath|
      require filepath.gsub(/.rb/,'')
    end
    # Upgrade 2.0.0 fine

    # Upgrade 2.0.0 inizio
    if defined?(Footnotes) && Rails.env.development?
      Footnotes.enabled = true
      Footnotes::Filter.prefix = 'txmt://open?url=file://%s&amp;line=%d&amp;column=%d'
    end
    # Upgrade 2.0.0 fine

  end
end
