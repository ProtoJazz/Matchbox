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

  def handle_event(
        "add_player_to_team",
        %{"team_id" => team_id, "summoner_name" => summoner_name},
        %{assigns: %{tournament: tournament}} = socket
      ) do
    {parsed_id, _} = Integer.parse(team_id)

    team = Enum.find(tournament.teams, nil, fn team -> team.id == parsed_id end)

    if(!is_nil(team)) do
      TournamentService.add_player(team, summoner_name)
      tournament = TournamentService.get_tournament(tournament.id)
      {:noreply, assign(socket, tournament: tournament)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("new_team", _, %{assigns: %{tournament: tournament}} = socket) do
    tournament_id = tournament.id
    team_name = "Team #{Faker.Food.ingredient()} #{Faker.Pokemon.name()}"
    TournamentService.add_team(tournament, team_name)

    tournament = TournamentService.get_tournament(tournament_id)

    {:noreply, assign(socket, tournament: tournament)}
  end

  def render(assigns) do
    ~L"""
      <div>
        <h3 style="color:white;"><%= @tournament.name %></h3>
        <button phx-click="new_team">Add Team</button>
        <h3 style="color:white;"> Teams: </h3>
        <ul>
          <%= for team <- @tournament.teams do %>
          <div class="card card_container_backer">
            <div class="card-content">
              <div class="media">
                <div class="media-content">
                  <p class="title is-4"><%= team.name %></p>
                </div>
              </div>

              <div class="content">
                <h3 style="color: white;">Members:</h3>

                <%= for player <- team.players do %>
                  <p><%= player.summoner_name %>
                <% end %>
                <form phx-submit="add_player_to_team">
                <div class="field" >
                  <label class="label">Add Summoner</label>
                  <div class="control">
                    <input type="hidden" value="<%= team.id %>" name="team_id"/>
                    <input style="color:black;" class="input" type="text" placeholder="Summoner Name" name="summoner_name">
                  </div>
                  <p class="help">We don't have the technology to update this later. Make sure its right</p>
                </div>
                <button style="color: black;" type="submit">Add</button>
                </form>
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
