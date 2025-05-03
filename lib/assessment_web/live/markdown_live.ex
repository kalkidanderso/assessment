defmodule AssessmentWeb.MarkdownLive do
  use AssessmentWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, 
      content: "# Welcome to Markdown Editor\n\nStart writing...",
      html_content: process_markdown("# Welcome to Markdown Editor\n\nStart writing...")
    )}
  end

  def handle_event("update_content", %{"content" => content}, socket) do
    html_content = process_markdown(content)
    {:noreply, assign(socket, content: content, html_content: html_content)}
  end

  def handle_event("export_pdf", _params, socket) do
    # Generate PDF using client-side JS instead of server-side
    {:noreply, push_event(socket, "export-pdf", %{html: socket.assigns.html_content})}
  end

  def handle_event("copy_html", _params, socket) do
    {:noreply, 
     socket
     |> put_flash(:info, "Content copied to clipboard!")
     |> push_event("copy-to-clipboard", %{content: socket.assigns.html_content})}
  end

  defp process_markdown(content) do
    case Earmark.as_html(content) do
      {:ok, html, _} -> html
      {:error, _html, _} -> "<p>Error processing markdown</p>"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="max-w-7xl mx-auto px-4 py-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <!-- Editor Pane -->
          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-bold text-gray-800">Markdown Editor</h2>
              <span class="text-sm text-gray-500">Live Preview</span>
            </div>
            <form phx-change="update_content" phx-submit="prevent_submit">
              <textarea 
                id="editor"
                name="content"
                class="w-full h-[60vh] p-4 border rounded-lg font-mono focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Write your markdown here..."
                phx-debounce="300"><%= @content %></textarea>
            </form>
          </div>

          <!-- Preview Pane -->
          <div class="bg-white rounded-lg shadow p-6">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-xl font-bold text-gray-800">Preview</h2>
              <div class="space-x-4">
                <button 
                  id="export-btn"
                  phx-click="export_pdf"
                  phx-hook="ExportPdf"
                  class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                  phx-disable-with="Exporting...">
                  Export PDF
                </button>
                <button 
                  id="copy-btn"
                  phx-click="copy_html"
                  phx-hook="CopyToClipboard"
                  class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
                  phx-disable-with="Copying...">
                  Copy
                </button>
              </div>
            </div>
            <div 
              id="preview"
              phx-hook="MarkdownPreview"
              class="prose max-w-none h-[60vh] overflow-y-auto p-4 border rounded-lg"
              data-html-content={@html_content}>
              <%= raw(@html_content) %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("prevent_submit", _params, socket) do
    {:noreply, socket}
  end
end