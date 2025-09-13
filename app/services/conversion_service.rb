require "prawn"
require "prawn-svg"

class ConversionService
  WATERMARK = "ann viss"

  # Initializes the service
  #
  # @param filename [String] Filename to use for temporary PDF
  # @param svg_content [String] SVG content to convert in PDF
  def initialize(filename, svg_content)
    @filename = filename
    @svg_content = svg_content
  end

  # Generates PDF and returns temporary file
  #
  # @return [Tempfile] Temporary file for generated PDF
  def call
    pdf_doc = create_pdf_with_frame
    file_path = save_temp_file(pdf_doc)

  end

  private
  # Creates PDF document with frame, SVG content and watermark
  #
  # @return [Prawn::Document] Generated PDF
  def create_pdf_with_frame
    Prawn::Document.new(
      page_size: "A4",
      margin: 0
    ).tap do |pdf|
      cm2pt = 28.35 #28.35 pt = 1cm in prawn
      content_margin = cm2pt
      content_padding = cm2pt
      content_width = pdf.bounds.width - (2 * content_margin)
      content_height = pdf.bounds.height - (2 * content_margin)

      pdf.bounding_box([content_margin, pdf.bounds.top - content_margin],
                       width: content_width) do
        draw_frame(pdf, pdf.bounds.width, content_height)
        pdf.move_down content_padding
        pdf.svg @svg_content, width: content_width
        draw_watermark(pdf)
        pdf.move_down content_padding
      end
    end
  end

  # Draws frame around content
  #
  # @param pdf [Prawn::Document] PDF document
  # @param width [Numeric] Width of the frame
  # @param height [Numeric] Height of the frame
  # @return [void]
  def draw_frame(pdf, width, height)
    pdf.stroke do
      pdf.rectangle([0, pdf.cursor], width, height)
      pdf.stroke_color "555555"
      pdf.line_width 2
    end
  end

  # Adds watermark to the PDF
  #
  # @param pdf [Prawn::Document] PDF document
  # @return [void]
  def draw_watermark(pdf)
    function = lambda {
      pdf.transparent(0.2) do
        pdf.formatted_text_box([{text: "#{WATERMARK}", font: "Helvetica", color: "7b7b7b", size: 120}],
                               rotate: 30, rotate_around: :center, align: :center, valign: :center)
      end
    }
    function.call
  end

  def save_temp_file(pdf_doc)
    tmp = Tempfile.new([Time.now.to_s, "-", @filename,".pdf"], binmode:true)
    tmp.write(pdf_doc.render)
    tmp.rewind
    tmp

  end
end



