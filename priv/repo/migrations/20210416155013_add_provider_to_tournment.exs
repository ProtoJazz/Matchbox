defmodule Matchbox.Repo.Migrations.AddProviderToTournment do
  use Ecto.Migration

  def change do
    alter table(:tournaments) do
      add :riot_tournament_id, :string
    end
  end
end
