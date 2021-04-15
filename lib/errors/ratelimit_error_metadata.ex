defmodule ExOsrsApi.Errors.RatelimitErrorMetadata do
  @enforce_keys [:limit, :extra_message]
  defstruct [:limit, :extra_message]

  @type t() :: %__MODULE__{
    limit: non_neg_integer(),
    extra_message: String.t()
  }
end
