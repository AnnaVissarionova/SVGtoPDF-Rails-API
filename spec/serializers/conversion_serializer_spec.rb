require 'rails_helper'

RSpec.describe ConversionSerializer do
  let(:blob) do
    double(
      'ActiveStorage::Blob',
      id: 1,
      filename: 'document.pdf',
      byte_size: 1024,
      pdf_url: 'blob_default_url'
    )
  end
  let(:pdf_url) { 'http://example.com/converted.pdf' }

  describe 'serialization' do
    context 'when pdf_url is provided in params' do
      let(:serializer) { described_class.new(blob, params: { pdf_url: pdf_url }) }

      it 'returns correct attributes' do
        result = serializer.serializable_hash

        expect(result[:data][:attributes][:filename]).to eq(blob.filename.to_s)
        expect(result[:data][:attributes][:byte_size]).to eq(blob.byte_size)
        expect(result[:data][:attributes][:download_url]).to eq(pdf_url)
      end

    end

    context 'when pdf_url is not provided' do
      let(:serializer) { described_class.new(blob) }

      it 'falls back to blob.pdf_url' do
        allow(blob).to receive(:pdf_url).and_return('blob_default_url')

        result = serializer.serializable_hash
        expect(result[:data][:attributes][:download_url]).to eq('blob_default_url')
      end

    end
  end
end