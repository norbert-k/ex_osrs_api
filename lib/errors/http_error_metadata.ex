defmodule ExOsrsApi.Errors.HttpErrorMetadata do
  @enforce_keys [:status_code, :extra_message, :headers]
  defstruct [:status_code, :extra_message, :headers]

  @type t() :: %__MODULE__{
          status_code: non_neg_integer(),
          extra_message: String.t(),
          headers: list()
        }

  @spec new(non_neg_integer(), String.t(), list()) :: t()
  def new(status_code, extra_message, headers) do
    %__MODULE__{
      status_code: status_code,
      extra_message: extra_message,
      headers: headers
    }
  end
end
