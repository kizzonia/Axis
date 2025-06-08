class ShipmentProofUploader < CarrierWave::Uploader::Base
  storage :fog
  # Optionally add versions, processing, white-listed extensions, etc.
  def store_dir
    "uploads/orders/#{model.id}/proofs"
  end

  def extension_allowlist
    %w[jpg jpeg png pdf]
  end
end
