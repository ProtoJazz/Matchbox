defmodule MatchboxWeb.MatchLive do
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
        <h3>some champions or someshit here</h3>
      </div>
    """
  end
end
