defmodule ExOsrsApi.PlayerRequest do
  @moduledoc """
  ### PlayerRequest
  For fine-tuned API requests
  """
  alias ExOsrsApi.OsrsApi

  @enforce_keys [:username, :types]
  defstruct [:username, :types]

  @type t() :: %__MODULE__{
          username: String.t(),
          types: list(OsrsApi.highscore_type())
        }

  @spec new(String.t(), list(OsrsApi.highscore_type())) :: t()
  @doc """
  Create new `PlayerRequest` for specific highscore_type requests
  """
  def new(username, types) when is_list(types) do
    %__MODULE__{
      username: username,
      types: types
    }
  end

  @spec new(String.t(), OsrsApi.highscore_type()) :: t()
  def new(username, type) when is_atom(type) do
    %__MODULE__{
      username: username,
      types: [type]
    }
  end
end
