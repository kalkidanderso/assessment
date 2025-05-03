defmodule AssessmentWeb.HelloLive do
  use AssessmentWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, message: "Hello World!")}
  end

  def render(assigns) do
    ~H"""
    <div class="grid h-screen place-items-center">
      <h1 class="text-4xl font-bold"><%= @message %></h1>
    </div>
    """
  end
end