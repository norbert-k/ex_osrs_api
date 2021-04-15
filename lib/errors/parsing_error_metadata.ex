defmodule ExOsrsApi.Errors.ParsingErrorMetadata do
  @enforce_keys [:name, :extra_message]
  defstruct [:name, :extra_message]

  @type t() :: %__MODULE__{
    name: String.t(),
    extra_message: String.t()
  }
end
