defmodule Matchbox.MatchState do
  defstruct red_team_bans: [],
            red_team_picks: [],
            blue_team_bans: [],
            blue_team_picks: [],
            current_pick: :blue,
            phase: :ban
end
