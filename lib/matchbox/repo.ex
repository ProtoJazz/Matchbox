defmodule Matchbox.Repo do
  use Ecto.Repo,
    otp_app: :matchbox,
    adapter: Ecto.Adapters.Postgres
end
