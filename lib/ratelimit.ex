defmodule ExOsrsApi.Ratelimit do
  @moduledoc """
  ### Ratelimit
  Ratelimit configuration

  * duration: duration of ratelimit in milliseconds
  * limit: maximum amount of requests in timeout duration
  """
  alias ExOsrsApi.Errors.Error
  alias ExOsrsApi.Errors.RatelimitErrorMetadata

  @enforce_keys [:limit, :timeout]
  defstruct [:limit, :timeout]

  @type t() :: %__MODULE__{
          limit: non_neg_integer(),
          timeout: non_neg_integer()
        }

  @doc """
  Create new ratelimit specification
  """
  @spec new(non_neg_integer(), non_neg_integer()) :: t()
  def new(limit, timeout) do
    %__MODULE__{
      limit: limit,
      timeout: timeout
    }
  end

  @doc """
  Create new default ratelimit specification (60 requests per second)
  """
  @spec new_default :: %ExOsrsApi.Ratelimit{:limit => 60, :timeout => 60000}
  def new_default() do
    %__MODULE__{
      limit: 60,
      timeout: 60_000
    }
  end

  @spec check_ratelimit(
          t(),
          :deadman
          | :hardcore_ironman
          | :ironman
          | :regular
          | :seasonal
          | :tournament
          | :ultimate_ironman
        ) :: {:ok, integer()} | {:error, Error.t()}
  def check_ratelimit(%__MODULE__{limit: limit, timeout: timeout}, type)
      when is_atom(type) and is_integer(timeout) and is_integer(limit) do
    case ExRated.check_rate("osrs-api-rate-limit-" <> Atom.to_string(type), timeout, limit) do
      {:ok, value} ->
        {:ok, value}

      {:error, limit} ->
        {:error,
         Error.new(
           :ratelimit_error,
           "Over the rate limit (limit: #{limit}, timeout: #{timeout})",
           RatelimitErrorMetadata.new(
             limit,
             "Over the rate limit (limit: #{limit}, timeout: #{timeout})"
           )
         )}
    end
  end
end
