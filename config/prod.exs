config :assessment, AssessmentWeb.Endpoint,
  cache_static_manifest: nil,  # Disable manifest check
  url: [host: "assessment-zreh.onrender.com", port: 443],
  server: true,
  force_ssl: [hsts: true]