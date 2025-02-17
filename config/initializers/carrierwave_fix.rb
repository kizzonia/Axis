# config/initializers/carrierwave_fix.rb
module CarrierWave
  module Uploader
    module Configuration
      def fog_provider=(provider)
        ActiveSupport::Deprecation.warn("fog_provider= is deprecated and will be removed in a future version.")
        self.fog_credentials = { provider: provider }
      end
    end
  end
end
