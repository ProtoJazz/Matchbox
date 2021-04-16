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

  def handle_event("new_team", _, %{assigns: %{tournament: tournament}} = socket) do
    tournament_id = tournament.id
    team_name = "Team #{Faker.Food.ingredient} #{Faker.Pokemon.name()}"
    TournamentService.add_team(tournament, team_name)

    tournament = TournamentService.get_tournament(tournament_id)

    {:noreply, assign(socket, tournament: tournament)}
  end

  def render(assigns) do
    ~L"""
      <div>
        <h3><%= @tournament.name %></h3>
        <button phx-click="new_team">Add Team</button>
        <h3> Teams: </h3>
        <ul>
          <%= for team <- @tournament.teams do %>
          <div class="card">
            <div class="card-content">
              <div class="media">
                <div class="media-content">
                  <p class="title is-4"><%= team.name %></p>
                </div>
              </div>

              <div class="content">
                <h3>Members:</h3>

                <%= for player <- team.players do %>
                  <p><%= player.summoner_name %>
                <% end %>
              </div>
            </div>
          </div>
          <li></li>
          <% end %>
        </ul>
        <button phx-click="start_match">New match</button>
      </div>
    """
  end
end
