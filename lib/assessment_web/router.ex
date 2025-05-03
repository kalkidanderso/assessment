# Inside router.ex or controller.ex where you're using the iframe
def export_pdf(conn, %{"html" => html}) do
  # Your PDF export logic here
  
  # Example of iframe creation with concatenation
  iframe_html = """
  <!DOCTYPE html>
  <html>
  <head>
    <title>Markdown Export</title>
    <style>
      body { font-family: system-ui, -apple-system, sans-serif; margin: 2cm; }
      h1, h2, h3 { color: #333; }
      pre { background: #f5f5f5; padding: 0.5em; border-radius: 4px; }
      code { font-family: monospace; }
      blockquote { border-left: 4px solid #ccc; padding-left: 1em; font-style: italic; }
      table { border-collapse: collapse; width: 100%; }
      th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
      a { color: #0066cc; text-decoration: none; }
    </style>
  </head>
  <body>
    #{html}
  </body>
  </html>
  """

  # Here you'd send iframe_html to be rendered or printed as PDF
  # Add your PDF rendering logic here
end
