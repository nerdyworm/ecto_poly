defmodule Repo do
  use Ecto.Repo,
    otp_app: :ecto_poly,
    adapter: Ecto.Adapters.Postgres
end
