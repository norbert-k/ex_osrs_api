defmodule ExOsrsApi.Models.ActivityEntry do
  @enforce_keys [:activity, :rank, :actions, :empty]
  defstruct [:activity, :rank, :actions, :empty]

  @type t() :: %__MODULE__{
          activity: atom(),
          rank: non_neg_integer() | nil,
          actions: non_neg_integer() | nil,
          empty: boolean()
        }

  @spec is_empty?(%ExOsrsApi.Models.ActivityEntry{}) :: boolean()
  def is_empty?(%__MODULE__{empty: empty}) do
    empty
  end

  @spec new_from_line(atom(), String.t()) ::
          {:error, String.t()} | {:ok, t()}
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
          :error -> {:error, "Error parsing ActivityEntry (activity: #{activity})"}
        end

      _ ->
        {:error, "Error parsing ActivityEntry (activity: #{activity})"}
    end
  end
end
