defmodule MatchboxWeb.TournamentLive do
  use MatchboxWeb, :live_view

  alias Matchbox.TournamentService

  @impl true
  def mount(%{"id" => tournament_id}, _session, socket) do

    tournament = TournamentService.get_tournament(tournament_id)

    {:ok, assign(socket, tournament: tournament)}
  end




  def render(assigns) do
    ~L"""
      <div>
        <h3><%= @tournament.name %></h3>
        <button>New match</button>
      </div>
    """
  end
end
