defmodule Matchbox.Match do
  alias Matchbox.MatchState
  alias Matchbox.Match

  defstruct state: %MatchState{},
            red_team: %{name: "Red Team", players: []},
            blue_team: %{name: "Blue Team", players: []},
            tournament_name: "Single Match",
            riot_tournament_id: 0,
            bans: 5,
            team_size: 5,
            champion_data: []

  use GenServer, restart: :transient

  @timeout 600_000

  def start_link(options) do
    GenServer.start_link(
      __MODULE__,
      initalize_match(options[:tournament_name], options[:champion_data], options[:red_team], options[:blue_team], options[:riot_tournament_id]),
      options
    )
  end

  def init(match) do
    {:ok, match, @timeout}
  end

  defp initalize_match(tournament_name, champion_data, red_team, blue_team, riot_tournament_id) do
    %Match{}
    |> setup_options(tournament_name, champion_data, red_team, blue_team, riot_tournament_id)
  end

  defp setup_options(match, tournament_name, champion_data, red_team, blue_team, riot_tournament_id) do
    %Match{match | tournament_name: tournament_name, champion_data: champion_data, red_team: red_team, blue_team: blue_team, riot_tournament_id: riot_tournament_id}
  end

  def state(%Match{state: state}) do
    state
  end

  def handle_call(:match, _from, match) do
    {:reply, match, match, @timeout}
  end

  def handle_cast({:pick, champ}, match) do
    {:noreply, Match.pick(match, champ), @timeout}
  end

  def get_picks(match) do
    if(match.state.phase == :pick) do
      if(match.state.current_pick == :blue) do
        match.state.blue_team_picks
      else
        match.state.red_team_picks
      end
    else
      if(match.state.current_pick == :blue) do
        match.state.blue_team_bans
      else
        match.state.red_team_bans
      end
    end
  end

  def swap_team(team) do
    if team == :red do
      :blue
    else
      :red
    end
  end

  def update_phase(match) do
    state = match.state

    if(state.phase == :ban) do
      if(
        Enum.count(state.blue_team_bans) >= match.bans and
          Enum.count(state.red_team_bans) >= match.bans
      ) do
        newState = %MatchState{match.state | phase: :pick}
        %Match{match | state: newState}
      else
        match
      end
    else
      match
    end
  end

  def update_team_picks(match, newPicks) do
    newTeam = swap_team(match.state.current_pick)

    if(match.state.phase == :pick) do
      if(match.state.current_pick == :blue) do
        if(Enum.count(match.state.blue_team_picks) < match.team_size) do
          %MatchState{match.state | blue_team_picks: newPicks, current_pick: newTeam}
        else
          %MatchState{match.state | current_pick: newTeam}
        end
      else
        if(Enum.count(match.state.red_team_picks) < match.team_size) do
          %MatchState{match.state | red_team_picks: newPicks, current_pick: newTeam}
        else
          %MatchState{match.state | current_pick: newTeam}
        end
      end
    else
      if(match.state.current_pick == :blue) do
        %MatchState{match.state | blue_team_bans: newPicks, current_pick: newTeam}
      else
        %MatchState{match.state | red_team_bans: newPicks, current_pick: newTeam}
      end
    end
  end

  def pick(match, champ) do
    currentPicks = get_picks(match)

    newpicks = currentPicks ++ [champ]
    newState = update_team_picks(match, newpicks)
    match = %Match{match | state: newState}
    update_phase(match)
  end
end
