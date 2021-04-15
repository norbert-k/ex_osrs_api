defmodule ExOsrsApi.Errors.Error do
  @enforce_keys [:type, :message]
  defstruct [:type, :message, :metadata]

  alias ExOsrsApi.Errors.HttpErrorMetadata
  alias ExOsrsApi.Errors.ParsingErrorMetadata
  alias ExOsrsApi.Errors.RatelimitErrorMetadata

  @type t() :: %__MODULE__{
          type:
            :http_error
            | :ratelimit_error
            | :parsing_error
            | :data_access_error
            | :task_error,
          message: String.t(),
          metadata:
            HttpErrorMetadata.t() | ParsingErrorMetadata.t() | RatelimitErrorMetadata.t() | nil
        }

  @spec new(:http_error, String.t(), HttpErrorMetadata.t()) :: t()
  def new(:http_error, message, %HttpErrorMetadata{} = metadata) do
    %__MODULE__{
      type: :http_error,
      message: message,
      metadata: metadata
    }
  end

  @spec new(:ratelimit_error, String.t(), RatelimitErrorMetadata.t()) :: t()
  def new(:ratelimit_error, message, %RatelimitErrorMetadata{} = metadata) do
    %__MODULE__{
      type: :ratelimit_error,
      message: message,
      metadata: metadata
    }
  end

  @spec new(:parsing_error, String.t(), ParsingErrorMetadata.t()) :: t()
  def new(:parsing_error, message, %ParsingErrorMetadata{} = metadata) do
    %__MODULE__{
      type: :parsing_error,
      message: message,
      metadata: metadata
    }
  end

  @spec new(:data_access_error, String.t()) :: t()
  def new(:data_access_error, message) do
    %__MODULE__{
      type: :data_access_error,
      message: message,
      metadata: nil
    }
  end

  @spec new(:task_error, String.t()) :: t()
  def new(:task_error, message) do
    %__MODULE__{
      type: :task_error,
      message: message,
      metadata: nil
    }
  end
end
