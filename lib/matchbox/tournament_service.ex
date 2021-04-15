defmodule Matchbox.TournamentService do
alias Matchbox.Repo
alias Matchbox.Tournament

def create_tournament(attrs \\ %{}) do
  %Tournament{}
  |> Tournament.changeset(attrs)
  |> Repo.insert()
end

def get_tournament(id) do
  Repo.get!(Tournament, id)
end

end
