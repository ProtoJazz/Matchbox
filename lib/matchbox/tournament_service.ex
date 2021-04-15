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

def start_match_server(match_id) do
  {:ok, _pid} =
    DynamicSupervisor.start_child(
      Matchbox.MatchSupervisor,
      {Matchbox.Match, name: via_tuple(match_id), tournament_name: "Single Match"}
    )
end

def pick_champ(match_id, champ) do
  :ok = GenServer.cast(via_tuple(match_id), {:pick, champ})
end

def get_match_server(match_id) do
  GenServer.call(via_tuple(match_id), :match)
end

defp via_tuple(name) do
  {:via, Registry, {Matchbox.MatchRegistry, name}}
end

end
