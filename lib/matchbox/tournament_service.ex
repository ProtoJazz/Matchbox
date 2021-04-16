defmodule Matchbox.TournamentService do
  alias Matchbox.Repo
  alias Matchbox.{Tournament, Team}
  import Ecto.Query
  def create_tournament(attrs \\ %{}) do
    %Tournament{}
    |> Tournament.changeset(attrs)
    |> Repo.insert()
  end

  def get_tournament(id) do
    Tournament |> preload([teams: :players]) |> Repo.get!(id)
  end

  def add_team(tournament, team_name) do
    %Team{}
    |> Team.changeset(tournament, %{name: team_name})
    |> Repo.insert()
  end

  @spec start_match_server(any) :: {:ok, pid}
  def start_match_server(match_id) do
    response =
      HTTPoison.get!("http://ddragon.leagueoflegends.com/cdn/11.8.1/data/en_US/champion.json")

    data = Jason.decode!(response.body)

    newValue =
      Enum.map(data["data"], fn {_key, champ} ->
        %{
          name: champ["name"],
          icon: champ["image"]["full"],
          splash: String.replace(champ["image"]["full"], ".png", "_0.jpg")
        }
      end)

    IO.inspect(newValue)

    {:ok, _pid} =
      DynamicSupervisor.start_child(
        Matchbox.MatchSupervisor,
        {Matchbox.Match,
         name: via_tuple(match_id), tournament_name: "Single Match", champion_data: newValue}
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
