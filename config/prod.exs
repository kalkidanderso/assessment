import Config

config :assessment, AssessmentWeb.Endpoint,
  url: [host: "assessment-30ga.onrender.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:assessment, :vsn)

config :logger, level: :info

config :phoenix, :serve_endpoints, true