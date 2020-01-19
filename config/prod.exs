use Mix.Config

config :expert_advice, ExpertAdviceWeb.Endpoint,
  url: [host: "localhost", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :expert_advice, ExpertAdvice.Repo,
  pool_size: 10
