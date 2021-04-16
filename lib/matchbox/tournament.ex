defmodule Matchbox.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tournaments" do
    field :name, :string
    has_many :teams, Matchbox.Team
    timestamps()
  end

  @doc false
  def changeset(tournament, attrs) do
    tournament
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

end
