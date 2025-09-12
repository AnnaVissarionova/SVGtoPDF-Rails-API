module Api
  module V1
    class ConversionsController < ApplicationController
      def create
        #ActionDispatch::Http::UploadedFile
        file = conversion_params[:svg_file]
        unless file && file.is_a?(ActionDispatch::Http::UploadedFile)
          render json: { error: "SVG file is required" },
                 status: :unprocessable_entity
        end


        begin
          tmp_file = ConversionService.new(file.original_filename, file.read).call
          blob = ActiveStorage::Blob.create_and_upload!(
            io: StringIO.new(tmp_file.read),
            filename: "converted-#{file.original_filename}.pdf",
            content_type: 'application/pdf'
          )

          pdf_url = url_for(blob)

          render json: ConversionSerializer.new(
            blob,
            params: { pdf_url: pdf_url }
          ).serializable_hash

        ensure
          if tmp_file
            tmp_file.close
            tmp_file.unlink if File.exist?(tmp_file.path)
          end
        end
      rescue => e
        render json: { error: "Conversion failed" }, status: :internal_server_error
      end

      def conversion_params
        params.permit(:authenticity_token, :svg_file)
      end

    end
  end
end