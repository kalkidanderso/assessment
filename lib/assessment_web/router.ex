defmodule AssessmentWeb.Router do
  use AssessmentWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AssessmentWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", AssessmentWeb do
    pipe_through :browser
    live "/", MarkdownLive
  end
end