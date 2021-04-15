defmodule ExOsrsApi.Errors.RatelimitErrorMetadata do
  @enforce_keys [:limit, :extra_message]
  defstruct [:limit, :extra_message]

  @type t() :: %__MODULE__{
          limit: non_neg_integer(),
          extra_message: String.t()
        }

  @spec new(non_neg_integer(), String.t()) :: t()
  def new(limit, extra_message) do
    %__MODULE__{
      limit: limit,
      extra_message: extra_message
    }
  end
end
