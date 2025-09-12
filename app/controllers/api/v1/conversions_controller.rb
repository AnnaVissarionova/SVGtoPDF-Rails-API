module Api
  module V1
    class ConversionsController < ApplicationController
      def create
        #ActionDispatch::Http::UploadedFile
        file = conversion_params[:svg_file]
        unless valid_file?(file)
          render json: { error: "SVG file is required" },
                 status: :unprocessable_entity
          return
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
        rescue => e
          render json: { error: "Conversion failed" }, status: :internal_server_error
        ensure
          if tmp_file
            tmp_file.close
            tmp_file.unlink if File.exist?(tmp_file.path)
          end
        end
      end

      private
      def conversion_params
        params.permit(:authenticity_token, :svg_file)
      end

      def valid_file?(file)
        return false unless file && file.is_a?(ActionDispatch::Http::UploadedFile)
        return false unless File.extname(file.original_filename).downcase == '.svg'
        valid_types = ['image/svg+xml', 'text/xml', 'application/xml']
        valid_types.include?(file.content_type)
      end

    end
  end
end