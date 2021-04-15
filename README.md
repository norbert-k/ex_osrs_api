# ExOsrsApi
Old-school Runescape Highscore API Wrapper

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_osrs_api` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_osrs_api, "~> 0.1.0"}
  ]
end
```

## Examples

### iex examples

```elixir
# Get regular (non ironman, deadman mode etc... highscores)
iex(1)> OsrsApi.get_highscores("BstnDynamics", :regular)

iex(2)> {:ok,
 %ExOsrsApi.PlayerHighscores{
   activities: %ExOsrsApi.Models.Activities{
     data: [
       %ExOsrsApi.Models.ActivityEntry{
         actions: nil,
         activity: "League Points",
         empty: true,
         rank: nil
       },
       ...
     ]
   }
  empty: false,
  skills: %ExOsrsApi.Models.Skills{
     data: [
       %ExOsrsApi.Models.SkillEntry{
         empty: false,
         experience: 8460220,
         level: 1205,
         rank: 1087587,
         skill: :overall
       },
       ...
     ]
  }
  type: :regular,
  username: "BstnDynamics"
 }}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_osrs_api](https://hexdocs.pm/ex_osrs_api).

