defmodule MatchboxWeb.MatchLive do
  use MatchboxWeb, :live_view

  alias Matchbox.TournamentService

  @impl true
  def mount(%{"id" => match_id}, _session, socket) do

    if connected?(socket), do: subscribe(match_id)
    socket = socket
    |> assign(match_id: match_id)
    |> assign_match()
    #{:noreply, socket}
    {:ok, socket}
  end

  def handle_event("select-champion", %{"champion" => champion}, socket) do
    socket =
      socket
      |> pick_champ(champion)

    {:noreply, socket}
  end


  def subscribe(match_id) do
    Phoenix.PubSub.subscribe(Matchbox.PubSub, match_id)
  end

  def handle_info(:update, socket) do
    {:noreply, assign_match(socket)}
  end

  defp pick_champ(%{assigns: %{match_id: match_id}} = socket, champ) do
    TournamentService.pick_champ(match_id, champ)
    :ok = Phoenix.PubSub.broadcast(Matchbox.PubSub, match_id, :update)
    socket
  end

  defp assign_match(%{assigns: %{match_id: match_id}} = socket) do
    match = TournamentService.get_match_server(match_id)
    state = Matchbox.Match.state(match)
    IO.puts("NEW STATE")
    IO.inspect(state)
    socket
    |> assign(
      match: match,
      state: state
    )
  end

  def render(assigns) do
    ~L"""
      <div>
        <h3>some champions or someshit here</h3>
        <button phx-click="select-champion" phx-value-champion="DrMundo">Pick Mundo</button>

        <ul>
         <%= for pick <- @state.red_team_picks do %>
            <li><%= pick %></li>
         <% end %>
        </ul>
      </div>
    """
  end
end
