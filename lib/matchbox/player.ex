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
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:summoner_name, :summoner_id])
    |> validate_required([:summoner_name, :summoner_id])
  end
end
