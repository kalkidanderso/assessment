defmodule AssessmentWeb.MarkdownLive do
  use AssessmentWeb, :live_view
  alias HtmlSanitizeEx.Scrubber.MarkdownHTML

  def mount(_params, _session, socket) do
    {:ok, assign(socket, content: "", html_content: "")}
  end

  def handle_event("update_content", %{"content" => content}, socket) do
    html = 
      content
      |> Earmark.as_html!()
      |> HtmlSanitizeEx.Scrubber.scrub(MarkdownHTML)
      
    {:noreply, assign(socket, content: content, html_content: html)}
  end

  def handle_event("export_pdf", _, %{assigns: %{html_content: html}} = socket) do
    {:ok, pdf_content} = PdfGenerator.generate(html, page_size: "A4")
    {:noreply, 
     socket
     |> put_resp_content_type("application/pdf")
     |> put_resp_header("content-disposition", "attachment; filename=export.pdf")
     |> send_resp(200, pdf_content)}
  end

  def handle_event("copy_html", _, socket) do
    {:noreply, 
     socket
     |> put_flash(:info, "Content copied to clipboard!")
     |> push_event("copy-to-clipboard", %{content: socket.assigns.html_content})}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="max-w-7xl mx-auto px-4 py-8">
        <div class="grid grid-cols-2 gap-8 h-screen">
          <!-- Editor Pane -->
          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-bold text-gray-800">Markdown Editor</h2>
              <span class="text-sm text-gray-500">Live Preview</span>
            </div>
            <textarea 
              id="editor"
              phx-keyup="update_content"
              phx-debounce="300"
              class="w-full h-[calc(100%-4rem)] p-4 border rounded-lg font-mono focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Write your markdown here..."><%= @content %></textarea>
          </div>

          <!-- Preview Pane -->
          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-bold text-gray-800">Preview</h2>
              <div class="space-x-4">
                <button 
                  class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                  phx-click="export_pdf">
                  Export PDF
                </button>
                <button 
                  class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
                  phx-click="copy_html">
                  Copy
                </button>
              </div>
            </div>
            <div 
              id="preview"
              class="prose h-[calc(100%-4rem)] overflow-y-auto"
              phx-update="ignore">
              <%= raw(@html_content) %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end