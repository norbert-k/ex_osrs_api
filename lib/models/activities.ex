defmodule ExOsrsApi.Models.Activities do
  alias ExOsrsApi.Models.ActivityEntry

  defstruct [:data]

  @type t() :: %__MODULE__{
          data: list(ActivityEntry.t())
        }

  @activities "League Points,Bounty Hunter - Hunter,Bounty Hunter - Rogue,Clue Scrolls (all),Clue Scrolls (beginner),Clue Scrolls (easy),
  Clue Scrolls (medium),Clue Scrolls (hard),Clue Scrolls (elite),Clue Scrolls (master),LMS - Rank,Soul Wars Zeal,Abyssal Sire,Alchemical Hydra,Barrows Chests,
  Bryophyta,Callisto,Cerberus,Chambers of Xeric,Chambers of Xeric: Challenge Mode,Chaos Elemental,Chaos Fanatic,Commander Zilyana,Corporeal Beast,Crazy Archaeologist,
  Dagannoth Prime,Dagannoth Rex,Dagannoth Supreme,Deranged Archaeologist,General Graardor,Giant Mole,Grotesque Guardians,Hespori,Kalphite Queen,King Black Dragon,Kraken,Kree'Arra,K'ril Tsutsaroth,Mimic,
  Nightmare,Obor,Sarachnis,Scorpia,Skotizo,Tempoross,The Gauntlet,The Corrupted Gauntlet,Theatre of Blood,Thermonuclear Smoke Devil,TzKal-Zuk,TzTok-Jad,Venenatis,Vet'ion,Vorkath,Wintertodt,Zalcano,Zulrah"
              |> String.replace("\n", "")
              |> String.split(",", trim: true)
              |> Enum.map(fn activity ->
                case String.replace(activity, ~r/\s+/, " ") do
                  " " <> activity -> activity
                  _ -> activity
                end
              end)

  @spec get_all_activities :: list(String.t())
  def get_all_activities() do
    @activities
  end

  @spec activities_length :: non_neg_integer
  def activities_length() do
    length(@activities)
  end

  @spec new_from_bitstring(list(String.t())) ::
          {:error, String.t()} | {:ok, t()}
  def new_from_bitstring(data) when is_list(data) do
    activity_data =
      data
      |> Enum.with_index()
      |> Enum.reduce_while({:ok, []}, fn {value, index}, {:ok, acc} ->
        case ActivityEntry.new_from_line(Enum.at(@activities, index), value) do
          {:ok, entry} -> {:cont, {:ok, [entry | acc]}}
          {:error, error} -> {:halt, {:error, error}}
        end
      end)

    case activity_data do
      {:ok, data} ->
        if length(data) == length(@activities) do
          {:ok,
           %__MODULE__{
             data: data |> Enum.reverse()
           }}
        else
          {:error, "Failed to parse activities (invalid length)"}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_activity_data(t(), String.t()) ::
          {:error, String.t()} | {:ok, ActivityEntry.t()}
  def get_activity_data(%__MODULE__{data: data}, activity) when is_bitstring(activity) do
    case Enum.find(data, fn %ActivityEntry{activity: activity} -> activity == activity end) do
      nil -> {:error, "Activity (#{activity}) not found"}
      value -> {:ok, value}
    end
  end
end
