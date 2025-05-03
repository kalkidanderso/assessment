defmodule AssessmentWeb.MarkdownLive do
  use AssessmentWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, content: "# Welcome", html_content: "")}
  end

  def handle_event("update_content", %{"content" => content}, socket) do
    {:noreply, assign(socket, content: content, html_content: content)}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-4 h-screen p-4">
      <textarea 
        phx-keyup="update_content" 
        phx-debounce="300"
        class="border p-2 h-full"
        ><%= @content %></textarea>
      <div class="border p-2 h-full">
        <%= @html_content %>
      </div>
    </div>
    """
  end
end