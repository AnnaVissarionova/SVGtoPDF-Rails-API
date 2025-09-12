class ConversionSerializer
  include JSONAPI::Serializer

  attributes :filename, :byte_size

  attribute :download_url do |object, params|
    params[:pdf_url] || object.pdf_url
  end

end