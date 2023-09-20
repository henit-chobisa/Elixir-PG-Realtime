defmodule Planerealtime.Repo do
  use Ecto.Repo,
    otp_app: :planerealtime,
    adapter: Ecto.Adapters.Postgres
end
