defmodule MatchboxWeb.DemoComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <ul>
      <%= for message <- @messages do %>
        <li>
          <%= message %>
        </li>
      <% end %>
    </ul>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
