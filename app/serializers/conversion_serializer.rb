# Serializer for PDF conversion results
class ConversionSerializer
  include JSONAPI::Serializer

  attributes :filename, :byte_size

  # Computed attribute for download URL of PDF
  attribute :download_url do |object, params|
    params[:pdf_url] || object.pdf_url
  end

end