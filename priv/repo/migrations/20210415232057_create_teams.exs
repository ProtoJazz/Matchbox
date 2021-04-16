defmodule Matchbox.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :tournament_id, :binary_id
      timestamps()
    end

  end
end
