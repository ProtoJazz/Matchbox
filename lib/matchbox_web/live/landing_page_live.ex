defmodule MatchboxWeb.LandingPageLive do
  use MatchboxWeb, :live_view

  alias Matchbox.TournamentService

  @impl true
  def mount(_params, _session, socket) do
    tournaments = TournamentService.get_tournaments()
    {:ok, assign(socket, tournaments: tournaments)}
  end


  def handle_event("create_tournament", _, socket) do
    name = "#{Faker.Company.name()} tournament to #{Faker.Company.bs()}"

    {:ok, tournament} = TournamentService.create_tournament(%{name: name})
    IO.inspect(tournament)
    IO.puts(Routes.tournament_path(socket, :show, tournament))
    {:noreply,  redirect(socket, to: Routes.tournament_path(socket, :show, tournament)
  )}
  end

  def render(assigns) do
    ~L"""
      <div>
        <button phx-click="create_tournament">New tournament</button>

        <%= for tournament <- @tournaments do %>
           <br/>
          <a href="/tournament/<%= tournament.id %>"><%= tournament.name %></a>
        <% end %>

      </div>
    """
  end
end
