class About < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
   mount_uploader :abtimg, AbtimgUploader
end
