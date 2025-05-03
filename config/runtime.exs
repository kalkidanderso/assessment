# config/runtime.exs
import Config

if System.get_env("PHX_SERVER") do
  config :assessment, AssessmentWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("RENDER_EXTERNAL_HOSTNAME") || "assessment-zreh.onrender.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :assessment, AssessmentWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    check_origin: [
      "https://#{host}",
      "//#{host}",
      "https://assessment-zreh.onrender.com",
      "//assessment-zreh.onrender.com"
    ],
    force_ssl: [hsts: true]

  # Configure PDF generator
  config :pdf_generator,
    wkhtml_path: System.get_env("WKHTMLTOPDF_PATH", "/usr/bin/wkhtmltopdf")
end