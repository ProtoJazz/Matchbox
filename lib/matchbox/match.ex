defmodule Matchbox.Match do
  alias Matchbox.MatchState
  alias Matchbox.Match
  defstruct state: %MatchState{}, red_name: "Red Team", blue_name: "Blue Team", tournament_name: "Single Match"

  use GenServer, restart: :transient

  @timeout 600_000

  def start_link(options) do
    GenServer.start_link(__MODULE__, initalize_match(options[:tournament_name]), options)
  end

  def init(match) do
    {:ok, match, @timeout}
  end

  defp initalize_match(tournament_name) do
    %Match{}
    |>setup_options(tournament_name)
  end

  defp setup_options(match, tournament_name) do
    %Match{match | tournament_name: tournament_name}
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

  def pick(match, champ) do
    newpicks = match.state.red_team_picks ++ [champ]
    newState = %MatchState{match.state | red_team_picks:  newpicks}
    %Match{match | state: newState}
  end

end
