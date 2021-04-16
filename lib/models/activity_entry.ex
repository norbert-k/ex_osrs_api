defmodule ExOsrsApi.Models.ActivityEntry do
  @moduledoc """
  ### ActivityEntry
  Represents Highscore activity data (League Points,Bounty Hunter - Hunter,Bounty Hunter - Rogue,Clue Scrolls (all),Clue Scrolls (beginner)...) entry
  """

  @enforce_keys [:activity, :rank, :actions, :empty]
  defstruct [:activity, :rank, :actions, :empty]

  alias ExOsrsApi.Errors.Error
  alias ExOsrsApi.Errors.ParsingErrorMetadata

  @type t() :: %__MODULE__{
          activity: String.t(),
          rank: 1..2_000_000 | nil,
          actions: non_neg_integer() | nil,
          empty: boolean()
        }

  @doc """
  Check if ActivityEntry is empty
  """
  @spec is_empty?(%ExOsrsApi.Models.ActivityEntry{}) :: boolean()
  def is_empty?(%__MODULE__{empty: empty}) do
    empty
  end

  @doc """
  Creates new `%ExOsrsApi.Models.ActivityEntry{}` from "CSV" like string seperated by commas ","
  """
  @spec new_from_line(String.t(), String.t()) ::
          {:error, Error.t()} | {:ok, t()}
  def new_from_line(activity, line) when is_bitstring(line) do
    case String.split(line, ",", trim: true) do
      ["-1", "-1"] ->
        {:ok,
         %__MODULE__{
           activity: activity,
           rank: nil,
           actions: nil,
           empty: true
         }}

      [rank, actions] ->
        with {rank, _} <- Integer.parse(rank),
             {actions, _} <- Integer.parse(actions) do
          {
            :ok,
            %__MODULE__{
              activity: activity,
              rank: rank,
              actions: actions,
              empty: false
            }
          }
        else
          :error ->
            {:error,
             Error.new(
               :parsing_error,
               "Failed to parse activity_entry",
               ParsingErrorMetadata.new(activity, "Failed to parse activity_entry")
             )}
        end

      _ ->
        {:error,
         Error.new(
           :parsing_error,
           "Failed to parse activity_entry",
           ParsingErrorMetadata.new(activity, "Failed to parse activity_entry")
         )}
    end
  end
end
