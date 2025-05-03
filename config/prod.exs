config :assessment, AssessmentWeb.Endpoint,
  url: [host: "assessment-30ga.onrender.com", port: 443],
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  check_origin: ["//assessment-30ga.onrender.com", "//*.onrender.com"],
  cache_static_manifest: "priv/static/cache_manifest.json"