defmodule ExOsrsApi.Errors.HttpErrorMetadata do
  @enforce_keys [:status_code, :extra_message, :headers]
  defstruct [:status_code, :extra_message, :headers]

  @type t() :: %__MODULE__{
    status_code: non_neg_integer(),
    extra_message: String.t(),
    headers: list()
  }
end
