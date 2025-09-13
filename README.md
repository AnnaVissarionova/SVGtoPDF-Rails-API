# SVG to PDF Converter

A web application that converts SVG files to PDF documents with automatic framing and watermarking features.

## Technology Stack

- **Backend**: Ruby on Rails, Prawn, Prawn-SVG
- **Frontend**: Tailwind CSS, Vanilla JavaScript
- **File Processing**: Active Storage, Tempfile
- **PDF Generation**: Prawn PDF library

## Installation

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd svg-to-pdf-converter
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```
3. **Start the server**:
   ```bash
   rails server
   ```
4. **Open your browser**:
  http://localhost:3000

## API

  ### Request
  ```http
  POST /api/v1/conversions
  Content-Type: multipart/form-data
  
  {
    "svg_file": [file],
    "authenticity_token": [token]
  }
```

### Response
```json
{
  "data": {
    "attributes": {
      "download_url": "/downloads/file.pdf",
      "byte_size": 10240
    }
  }
}
```
