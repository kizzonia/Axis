# if Rails.env.production?
# require 'carrierwave/storage/fog'
# # config/initializers/carrierwave.rb
# CarrierWave.configure do |config|
#   config.fog_provider = 'fog/aws' # Use 'fog-aws' if you're using the fog-aws gem
#   config.fog_credentials = {
#     provider:              'AWS',
#     aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
#     aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
#     region:                ENV['AWS_REGION']
#   }
#   config.fog_directory  = ENV['AWS_BUCKET']
#   config.fog_public     = false
#   config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
# end
# end

if Rails.env.production?
require 'carrierwave/storage/fog'
CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'fog/aws',                        # required
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],                        # required unless using use_iam_profile
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],                        # required unless using use_iam_profile
    use_iam_profile:       true,                         # optional, defaults to false
    region:                ENV['AWS_REGION'],                  # optional, defaults to 'us-east-1'
    # host:                  's3.example.com',             # optional, defaults to nil
    # endpoint:              'https://s3.example.com:8080' # optional, defaults to nil
  }
  config.fog_directory  = ENV['AWS_BUCKET']                                     # required
  config.fog_public     = false                                                 # optional, defaults to true
  config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" } # optional, defaults to {}
  # Use this if you have AWS S3 ACLs disabled.
  # config.fog_attributes = { 'x-amz-acl' => 'bucket-owner-full-control' }
  # Use this if you have Google Cloud Storage uniform bucket-level access enabled.
  # config.fog_attributes = { uniform: true }
  # For an application which utilizes multiple servers but does not need caches persisted across requests,
  # uncomment the line :file instead of the default :storage.  Otherwise, it will use AWS as the temp cache store.
  # co
end
end
