class BookImageUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave
  include CarrierWave::MiniMagick
  
  process :resize_to_fit => [300, 400]

  version :thumb do
    process :resize_to_fit => [150, 200]
  end
end
