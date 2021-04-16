defmodule ExOsrsApi.Errors.Error do
  @moduledoc """
  Represents ExOsrsApi Error,
  Types or errors: [`:http_error`, `:ratelimit_error`, `:parsing_error`, `:data_access_error`, `:task_error`]

  #### http_error
  Represents underlying http error (404, 500 etc.., non 2XX status codes)
  #### ratelimit_error
  `ex_rated` ratelimit error when going over configured rate limit
  #### parsing_error
  API parsing error (when parsing CSV like highscore API data)
  #### data_access_error
  When accessing `skills` or `activities` data that doesn't exist
  #### task_error
  Represents `Task.async` errors when executing multiple requests
  """
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
