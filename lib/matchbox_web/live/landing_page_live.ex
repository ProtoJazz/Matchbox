defmodule MatchboxWeb.LandingPageLive do
  use MatchboxWeb, :live_view

  alias Matchbox.TournamentService

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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
      </div>
    """
  end
end
