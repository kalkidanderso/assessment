defmodule AssessmentWeb.MarkdownLive do
  use AssessmentWeb, :live_view
  alias HtmlSanitizeEx.Scrubber.MarkdownHTML
  alias PdfGenerator

  def mount(_params, _session, socket) do
    {:ok, assign(socket, 
      content: "# Welcome to Markdown Editor\n\nStart writing...",
      html_content: "",
      pdf_url: nil
    )}
  end

  def handle_event("update_content", %{"content" => content}, socket) do
    html = process_markdown(content)
    {:noreply, assign(socket, content: content, html_content: html)}
  end

  def handle_event("export_pdf", _, socket) do
    {:ok, pdf_content} = generate_pdf(socket.assigns.html_content)
    url = create_temporary_url(pdf_content)
    {:noreply, assign(socket, pdf_url: url)}
  end

  def handle_event("copy_html", _, socket) do
    {:noreply, 
     socket
     |> put_flash(:info, "Content copied to clipboard!")
     |> push_event("copy-to-clipboard", %{content: socket.assigns.html_content})}
  end

  def handle_info({:send_pdf, url}, socket) do
    {:noreply, 
     socket
     |> push_event("trigger-download", %{url: url})
     |> assign(pdf_url: nil)}
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
                  phx-click="export_pdf"
                  phx-disable-with="Generating...">
                  Export PDF
                </button>
                <button 
                  class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
                  phx-click="copy_html"
                  phx-disable-with="Copying...">
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
    
    <%= if @pdf_url do %>
      <div id="pdf-download" phx-hook="PdfDownload"></div>
    <% end %>
    """
  end

  defp process_markdown(content) do
    content
    |> Earmark.as_html!()
    |> HtmlSanitizeEx.Scrubber.scrub(MarkdownHTML)
  end

  defp generate_pdf(html) do
    PdfGenerator.generate(html,
      page_size: "A4",
      encoding: "UTF-8",
      delete_temporary: true
    )
  end

  defp create_temporary_url(content) do
    blob = Blob.new(content, type: "application/pdf")
    Url.createObjectURL(blob)
  end
end