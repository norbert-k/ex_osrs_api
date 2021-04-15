defmodule ExOsrsApi.Errors.ParsingErrorMetadata do
  @enforce_keys [:name, :extra_message]
  defstruct [:name, :extra_message]

  @type t() :: %__MODULE__{
          name: String.t(),
          extra_message: String.t()
        }

  @spec new(String.t(), String.t()) :: t()
  def new(name, extra_message) do
    %__MODULE__{
      name: name,
      extra_message: extra_message
    }
  end
end
