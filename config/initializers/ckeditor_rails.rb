Ckeditor::Rails.configure do |config|
  # default is nil for all languages, or set as %w[en zh]
  config.assets_languages = nil

  # default is nil for all plugins,
  # or set as white list: %w[image link liststyle table tabletools]
  # or set as black list: config.default_plugins - %w[about a11yhelp]
  config.assets_plugins = nil

  # default is nil for all skins, or set as %w[moono-lisa]
  config.assets_skins = nil

  # default is nil and it will be "#{::Sprockets::Railtie.config.assets.prefix}/ckeditor",
  # or set as String like '/assets/ckeditor',
  # or set as Proc / Lambda
  # no slash in the end
  config.assets_base_path = nil
end
