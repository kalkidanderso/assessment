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

  # Get Render's external hostname (ensure this matches your actual URL)
  host = System.get_env("RENDER_EXTERNAL_HOSTNAME") || "assessment-30ga.onrender.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :assessment, AssessmentWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    check_origin: false,  # TEMPORARY - for testing only
    force_ssl: [hsts: true]

  # IMPORTANT: After confirming it works, change check_origin to:
  # check_origin: [
  #   "https://#{host}",
  #   "//#{host}",
  #   "https://assessment-30ga.onrender.com",
  #   "//assessment-30ga.onrender.com"
  # ]
end