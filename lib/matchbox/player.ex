defmodule Matchbox.Player do
  use Ecto.Schema
  alias Matchbox.Team
  import Ecto.Changeset

  schema "players" do
    field :summoner_id, :string
    field :summoner_name, :string
    belongs_to :team, Team
    timestamps()
  end

  @doc false
  def changeset(player, team, attrs) do
    player
    |> cast(attrs, [:summoner_name, :summoner_id])
    |> put_assoc(:team, team)
    |> validate_required([:summoner_name])
  end
end
