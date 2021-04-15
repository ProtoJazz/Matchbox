defmodule MatchboxWeb.TournamentLive do
  use MatchboxWeb, :live_view

  alias Matchbox.TournamentService

  @impl true
  def mount(%{"id" => tournament_id}, _session, socket) do

    tournament = TournamentService.get_tournament(tournament_id)

    {:ok, assign(socket, tournament: tournament)}
  end

  def handle_event("start_match", _, socket) do
    match_id = UUID.uuid4()
    TournamentService.start_match_server(match_id)

    {:noreply,
    push_redirect(
      socket,
      to: Routes.match_path(socket, :show, match_id)
    )}
  end

  def render(assigns) do
    ~L"""
      <div>
        <h3><%= @tournament.name %></h3>
        <button phx-click="start_match">New match</button>
      </div>
    """
  end
end
