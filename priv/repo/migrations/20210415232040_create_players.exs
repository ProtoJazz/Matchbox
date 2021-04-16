defmodule Matchbox.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :summoner_name, :string
      add :summoner_id, :string
      add :team_id, :integer
      timestamps()
    end

  end
end
