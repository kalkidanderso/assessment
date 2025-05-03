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

  # Get Render's external hostname from environment variables
  render_host = System.get_env("RENDER_EXTERNAL_HOSTNAME") || "assessment-30ga.onrender.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :assessment, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :assessment, AssessmentWeb.Endpoint,
    url: [
      host: render_host,
      port: 443,
      scheme: "https"
    ],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    check_origin: [
      # Allow requests from your specific Render URL
      "https://#{render_host}",
      # Allow all Render subdomains
      "//*.onrender.com",
      # Allow localhost for potential future development
      "//localhost*",
      "//127.0.0.1*"
    ],
    force_ssl: [
      hsts: true,
      rewrite_on: [:x_forwarded_proto]
    ]

  # SSL configuration (keep commented unless you add SSL certs)
  # config :assessment, AssessmentWeb.Endpoint,
  #   https: [
  #     port: 443,
  #     cipher_suite: :strong,
  #     keyfile: System.get_env("SSL_KEY_PATH"),
  #     certfile: System.get_env("SSL_CERT_PATH")
  #   ]
end