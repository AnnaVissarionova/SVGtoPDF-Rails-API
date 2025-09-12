require 'rails_helper'

RSpec.describe Api::V1::ConversionsController, type: :request do
  describe 'POST /api/v1/conversions' do
    let(:valid_file) { fixture_file_upload('spec/fixtures/files/test.svg', 'image/svg+xml') }
    let(:invalid_file) { fixture_file_upload('spec/fixtures/files/invalid_file.txt', 'text/plain') }

    # before do
    #   allow_any_instance_of(ConversionService).to receive(:call).and_return(Tempfile.new(["converted", ".pdf"]))
    # end

    context 'valid svg file' do
      before do
        post '/api/v1/conversions', params: { svg_file: valid_file }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns pdf url' do
        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']['download_url']).to be_present
      end

      it 'returns valid pdf url' do
        json_response = JSON.parse(response.body)
        url = json_response.dig('data', 'attributes', 'download_url')

        expect(url).to be_present
        expect(url).to match(%r{^http://})
        expect(url).to include('.pdf')
        expect(url).to include('/rails/active_storage/blobs/')
      end

      it 'returns filename' do
        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']['filename']).to end_with('.pdf')
      end


      it 'returns file size' do
        json_response = JSON.parse(response.body)
        expected_size = blob = ActiveStorage::Blob.last.byte_size

        expect(json_response['data']['attributes']['byte_size']).to eq(expected_size)
      end


      it "returns error when conversion failed" do
        allow_any_instance_of(ConversionService).to receive(:call).and_raise("fail")
        post "/api/v1/conversions", params: { svg_file: valid_file }
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)["error"]).to eq("Conversion failed")
      end


    end

    context 'invalid file' do
      it 'returns error when no file provided' do
        post '/api/v1/conversions'
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('SVG file is required')
      end

      it 'returns error when wrong file type' do
        post '/api/v1/conversions', params: { svg_file: invalid_file }
        expect(response).to have_http_status(:unprocessable_entity)
      end


    end
  end
end