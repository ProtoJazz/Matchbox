defmodule Matchbox.TournamentService do
  alias Matchbox.Repo
  alias Matchbox.{Tournament, Team, Player}
  import Ecto.Query
  def create_tournament(attrs \\ %{}) do
    riot_id = get_riot_tournament_id(attrs.name)
    attrs = Map.put_new(attrs, :riot_tournament_id, riot_id)
    %Tournament{}
    |> Tournament.changeset(attrs)
    |> Repo.insert()
  end

  def get_tournament_code(red_team, blue_team, team_size, tournament_id) do
    red_team_ids = Enum.map(red_team.players, fn player -> player.summoner_id end)
    blue_team_ids = Enum.map(blue_team.players, fn player -> player.summoner_id end)
    summoner_ids = red_team_ids ++ blue_team_ids

    rawBody = %{allowedSummonerIds: summoner_ids, mapType: "SUMMONERS_RIFT", pickType: "BLIND_PICK", spectatorType: "ALL", teamSize: team_size}
    url = "https://americas.api.riotgames.com/lol/tournament-stub/v4/codes?tournamentId=#{tournament_id}"
    payload = Jason.encode!(rawBody)
    headers = ["X-Riot-Token": "#{Application.get_env(:matchbox, :riot_key)}"]
    {:ok, response} = HTTPoison.post(url, payload, headers)
    response.body
  end

  def get_riot_tournament_id(tournament_name) do

    url = "https://americas.api.riotgames.com/lol/tournament-stub/v4/tournaments"
    rawBody = %{name: tournament_name, providerId: Application.get_env(:matchbox, :provider_id)}
    payload = Jason.encode!(rawBody)
    headers = ["X-Riot-Token": "#{Application.get_env(:matchbox, :riot_key)}"]
    {:ok, response} = HTTPoison.post(url, payload, headers)
    response.body
  end

  def get_tournament(id) do
    Tournament |> preload([teams: :players]) |> Repo.get!(id)
  end

  def add_team(tournament, team_name) do
    %Team{}
    |> Team.changeset(tournament, %{name: team_name})
    |> Repo.insert()
  end

  def add_player(team, summoner_name) do

    summoner_id = get_summoner_id(summoner_name)

    %Player{}
    |> Player.changeset(team, %{summoner_name: summoner_name, summoner_id: summoner_id})
    |> Repo.insert()
  end

  def get_summoner_id(summoner_name) do

    url = "https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{summoner_name}"
    headers = ["X-Riot-Token": "#{Application.get_env(:matchbox, :riot_key)}"]
    {:ok, response} = HTTPoison.get(url, headers)
    data = Jason.decode!(response.body)
    data["id"]
  end

  def start_match_server(match_id, red_team, blue_team, riot_tournament_id) do
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
         name: via_tuple(match_id), tournament_name: "Single Match", champion_data: newValue, red_team: red_team, blue_team: blue_team, riot_tournament_id: riot_tournament_id}
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
