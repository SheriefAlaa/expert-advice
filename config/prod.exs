use Mix.Config

config :expert_advice, ExpertAdviceWeb.Endpoint,
  http: [port: 4040],
  url: [host: "localhost", port: 4040],
  debug_errors: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :expert_advice, ExpertAdvice.Repo,
  pool_size: 10
