defmodule MatchboxWeb.MatchLive do
  use MatchboxWeb, :live_view

  alias Matchbox.TournamentService
  @iconRoot "http://ddragon.leagueoflegends.com/cdn/11.8.1/img/champion/"
  @splashRoot "http://ddragon.leagueoflegends.com/cdn/img/champion/loading/"
  @impl true
  def mount(%{"id" => match_id}, _session, socket) do
    if connected?(socket), do: subscribe(match_id)

    socket =
      socket
      |> assign(match_id: match_id)
      |> assign_match()

    # {:noreply, socket}
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

    socket
    |> assign(
      match: match,
      state: state
    )
  end

  def imgUrl(champion) do
    "#{@iconRoot}#{champion.icon}"
  end

  def splashUrl(champion, champion_data) do
    champion =
      Enum.find(champion_data, nil, fn c ->
        c.name == champion
      end)

    "#{@splashRoot}#{champion.splash}"
  end

  def render(assigns) do
    ~L"""
      <div>
        <div class="tile is-ancestor">
          <div class="tile red">
            <div class="title_team_name">
              <%= @match.red_name %>
            </div>
          </div>
          <div class="tile blue">
            <div class="title_team_name">
            <%= @match.blue_name %>
            </div>
          </div>
        </div>

        <div class="champ_select_backer">
          <div class="tile is-ancestor">
            <%= for index <- 0..@match.team_size - 1 do %>
              <% selection = Enum.at(@state.red_team_picks, index) %>
              <%= if is_nil(selection) do %>
                <div class="tile no_champ champ_portrait">
                  <img src="https://i.kym-cdn.com/entries/icons/original/000/036/482/cover5.jpg"/>
                </div>
              <% else %>
                <div class="tile champ_portrait">
                  <img class="tile" src = "<%=splashUrl(selection, @match.champion_data)%>"/>
                </div>
              <% end %>
            <% end %>

            <div class="tile champ_divider" ></div>

            <%= for index <- Enum.reverse(0..@match.team_size - 1) do %>
              <% selection = Enum.at(@state.blue_team_picks, index) %>
              <%= if is_nil(selection) do %>
                <div class="tile no_champ champ_portrait">
                  <img src="https://i.kym-cdn.com/entries/icons/original/000/036/482/cover5.jpg"/>
                </div>
              <% else %>
                <div class="tile champ_portrait">
                  <img class="tile" src = "<%=splashUrl(selection, @match.champion_data)%>"/>
                </div>
              <% end %>
            <% end %>
          </div>

          <div class="tile is-ancestor">
            <%= for index <- 0..@match.bans - 1 do %>
              <% selection = Enum.at(@state.red_team_bans, index) %>
              <%= if is_nil(selection) do %>
                <div class="tile no_champ champ_portrait">
                  <img src="https://i.kym-cdn.com/entries/icons/original/000/036/482/cover5.jpg"/>
                </div>
              <% else %>
                <div class="tile champ_portrait banned">
                  <img class="tile" src = "<%=splashUrl(selection, @match.champion_data)%>"/>
                </div>
              <% end %>
            <% end %>

            <div class="tile champ_divider"></div>

            <%= for index <- Enum.reverse(0..@match.bans - 1) do %>
              <% selection = Enum.at(@state.blue_team_bans, index) %>
              <%= if is_nil(selection) do %>
                <div class="tile no_champ champ_portrait">
                  <img src="https://i.kym-cdn.com/entries/icons/original/000/036/482/cover5.jpg"/>
                </div>
              <% else %>
                <div class="tile champ_portrait banned">
                  <img class="tile" src = "<%=splashUrl(selection, @match.champion_data)%>"/>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
        <div class="columns is-multiline is-gapless">
          <%= for champion <- @match.champion_data do %>
            <div class="column is-1">
              <img  phx-click="select-champion" phx-value-champion="<%= champion.name %>" src="<%=imgUrl(champion)%>"/>
            </div>
          <% end %>
        </div>
      </div>
    """
  end
end
