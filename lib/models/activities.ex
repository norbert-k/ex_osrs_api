defmodule ExOsrsApi.Models.Activities do
  alias ExOsrsApi.Models.ActivityEntry
  alias ExOsrsApi.Errors.Error
  alias ExOsrsApi.Errors.ParsingErrorMetadata

  defstruct [:data]

  @type t() :: %__MODULE__{
          data: list(ActivityEntry.t())
        }

  @default_acitivites "League Points,Bounty Hunter - Hunter,Bounty Hunter - Rogue,Clue Scrolls (all),Clue Scrolls (beginner),Clue Scrolls (easy),
  Clue Scrolls (medium),Clue Scrolls (hard),Clue Scrolls (elite),Clue Scrolls (master)"
                      |> String.replace("\n", "")
                      |> String.split(",", trim: true)
                      |> Enum.map(fn activity ->
                        case String.replace(activity, ~r/\s+/, " ") do
                          " " <> activity -> activity
                          _ -> activity
                        end
                      end)

  @minigame_activities "LMS - Rank,Soul Wars Zeal"
                       |> String.split(",", trim: true)
                       |> Enum.map(fn activity ->
                         case String.replace(activity, ~r/\s+/, " ") do
                           " " <> activity -> activity
                           _ -> activity
                         end
                       end)

  @pvm_activities "Abyssal Sire,Alchemical Hydra,Barrows Chests,
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

  @activities @default_acitivites ++ @minigame_activities ++ @pvm_activities

  @doc """
  Get all suported activities
  """
  @spec get_all_default_activities :: [String.t(), ...]
  def get_all_default_activities() do
    @activities
  end

  @doc """
  Get suported activities list length
  """
  @spec default_activities_length :: non_neg_integer
  def default_activities_length() do
    length(@activities)
  end

  @doc """
  Creates new `%ExOsrsApi.Models.Activities{}` from "CSV" like string seperated by newlines `"\n"`

  You can supply your own activity list by specifying second argument with your own list of activities (list of strings)
  """
  @spec new_from_bitstring(list(String.t()), list(String.t())) ::
          {:error, Error.t()} | {:ok, t()}
  def new_from_bitstring(data, supported_activities \\ @activities) when is_list(data) do
    activity_data =
      data
      |> Enum.with_index()
      |> Enum.reduce_while({:ok, []}, fn {value, index}, {:ok, acc} ->
        case ActivityEntry.new_from_line(Enum.at(supported_activities, index), value) do
          {:ok, entry} -> {:cont, {:ok, [entry | acc]}}
          {:error, error} -> {:halt, {:error, error}}
        end
      end)

    case activity_data do
      {:ok, data} ->
        if length(data) == length(supported_activities) do
          {:ok,
           %__MODULE__{
             data: data |> Enum.reverse()
           }}
        else
          {:error,
           Error.new(
             :parsing_error,
             "Failed to parse activities (invalid length)",
             ParsingErrorMetadata.new("activities", "Failed to parse activities (invalid length)")
           )}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_activity_data(t(), String.t()) ::
          {:error, String.t()} | {:ok, ActivityEntry.t()}
  def get_activity_data(%__MODULE__{data: data}, activity) when is_bitstring(activity) do
    case Enum.find(data, fn %ActivityEntry{activity: x} -> x == activity end) do
      nil -> {:error, Error.new(:data_access_error, "Activity (#{activity}) not found")}
      value -> {:ok, value}
    end
  end
end
