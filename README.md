# ExOsrsApi
Old-school Runescape Highscore API Wrapper

[https://hexdocs.pm/ex_osrs_api](https://hexdocs.pm/ex_osrs_api)
## Installation

Package can be installed by adding `ex_osrs_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_osrs_api, "~> 1.0"}
  ]
end
```

## Versioning & Notes

Package is updated every time jagex introduces new activity (patch version bump), old packages will fail to parse activity data if they're not updated to latest version, so always specify `{:ex_osrs_api, "~> 1.0"}` version to get latest support for ever changing Highscore API support.

Latest Supported activities:
* Tempoross - package version `"1.0.0"` : `{:ex_osrs_api, "~> 1.0.0"}`

## Examples

Supported highscore types:
```elixir
:deadman # Deadman mode
:hardcore_ironman # Hardcore Ironman
:ironman # Ironman
:regular # Regular highscores
:seasonal # Seasonal
:tournament # Tournament
:ultimate_ironman # Ultimate Ironman
```

`ExOsrsApi.PlayerRequest` API Examples
```elixir
alias ExOsrsApi.OsrsApi
alias ExOsrsApi.PlayerRequest

# Create new player request for regular highscores
character_request = PlayerRequest.new("BstnDynamics", :regular)

# Create new player request for regular and ironman highscores
character_request_2 = PlayerRequest.new("BstnDynamics", [:regular, :ironman])

# Request single player_request
OsrsApi.get_player_request(character_request)

# Request multiple player_requests
OsrsApi.get_multiple_player_request([character_request, character_request_2])
```

Regular API Examples
```elixir

# Get regular highscores for BstnDynamics player
OsrsApi.get_highscores("BstnDynamics", :regular)

# Get all highscore types for BstnDynamics player
OsrsApi.get_all_highscores("BstnDynamics")

# Get multiple user regular highscores
OsrsApi.get_multiple_highscores(["BstnDynamics", "mystAvery"], :regular)

# Get multiple user ironman highscores
OsrsApi.get_multiple_highscores(["BstnDynamics", "mystAvery"], :ironman)

# Get multiple user highscores for every supported highscore type
OsrsApi.get_multiple_all_highscores(["BstnDynamics", "mystAvery"])
```