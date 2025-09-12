require "prawn"
require "prawn-svg"

class ConversionService
  WATERMARK = 'Ann V'
  def initialize(filename, svg_content)
    @filename = filename
    @svg_content = svg_content
  end

  def call
    pdf_doc = create_pdf_with_frame
    file_path = save_temp_file(pdf_doc)

  end

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
        pdf.move_down content_padding
      end
    end
  end

  def draw_frame(pdf, width, height)
    pdf.stroke do
      pdf.rectangle([0, pdf.cursor], width, height)
      pdf.stroke_color "555555"
      pdf.line_width 2
    end
  end

  def save_temp_file(pdf_doc)
    tmp = Tempfile.new([Time.now.to_s, '-', @filename,'.pdf'], binmode:true)
    tmp.write(pdf_doc.render)
    tmp.rewind
    tmp

  end
end



