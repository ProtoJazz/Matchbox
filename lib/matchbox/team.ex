defmodule Matchbox.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :name, :string
    has_many :players, Matchbox.Player
    belongs_to :tournament, Matchbox.Tournament, foreign_key: :tournament_id, type: :binary_id, primary_key: true
    timestamps()
  end

  @doc false
  def changeset(team, tournament, attrs) do
    team
    |> cast(attrs, [:name])
    |> put_assoc(:tournament, tournament)
    |> validate_required([:name])
  end
end
