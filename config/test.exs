import Config

config :logger, level: :warning

config :ecto_poly, ecto_repos: [Repo]

config :ecto_poly, Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ecto_poly_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
