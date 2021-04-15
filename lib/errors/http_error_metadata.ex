defmodule ExOsrsApi.Errors.HttpErrorMetadata do
  @enforce_keys [:status_code, :extra_message, :headers, :requested_type]
  defstruct [:status_code, :extra_message, :headers, :requested_type]

  @type t() :: %__MODULE__{
          status_code: non_neg_integer() | nil,
          extra_message: String.t() | atom(),
          headers: list(),
          requested_type:
            :deadman
            | :hardcore_ironman
            | :ironman
            | :regular
            | :seasonal
            | :tournament
            | :ultimate_ironman
        }

  @spec new(
          non_neg_integer() | nil,
          String.t() | atom(),
          list(),
          :deadman
          | :hardcore_ironman
          | :ironman
          | :regular
          | :seasonal
          | :tournament
          | :ultimate_ironman
        ) :: t()
  def new(status_code, extra_message, headers, requested_type) do
    %__MODULE__{
      status_code: status_code,
      extra_message: extra_message,
      headers: headers,
      requested_type: requested_type
    }
  end
end
