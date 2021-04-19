defmodule ExOsrsApi.OsrsApi do
  @moduledoc """
  ### OsrsApi
  Main module for API requests
  """
  use Tesla, only: ~w(get)a, docs: false

  alias ExOsrsApi.Ratelimit
  alias ExOsrsApi.PlayerHighscores
  alias ExOsrsApi.Errors.Error
  alias ExOsrsApi.Errors.HttpErrorMetadata
  alias ExOsrsApi.PlayerRequest
  alias ExOsrsApi.Models.Activities

  @highscore_types ~w(regular ironman hardcore_ironman ultimate_ironman deadman seasonal tournament)a

  @default_ratelimiter Ratelimit.new_default()

  adapter(Tesla.Adapter.Hackney)

  plug(Tesla.Middleware.Timeout, timeout: 20_000)
  plug(Tesla.Middleware.BaseUrl, "https://secure.runescape.com/")
  plug(Tesla.Middleware.Compression, format: "gzip")

  plug(Tesla.Middleware.Fuse,
    opts: {{:standard, 10, 10_000}, {:reset, 30_000}},
    keep_original_error: true,
    should_melt: fn
      {:ok, %{status: status}} when status in [428, 500, 504] -> true
      {:ok, _} -> false
      {:error, _} -> true
    end
  )

  @typedoc """
  Supported highscore types
  """
  @type highscore_type ::
          :deadman
          | :hardcore_ironman
          | :ironman
          | :regular
          | :seasonal
          | :tournament
          | :ultimate_ironman

  @spec get_highscores(
          String.t(),
          highscore_type(),
          Ratelimit.t(),
          list(String.t())
        ) :: {:error, Error.t()} | {:ok, PlayerHighscores.t()}
  @doc """
  Get player highscores by player username and highscore type
  """
  def get_highscores(
        username,
        type,
        ratelimit \\ @default_ratelimiter,
        supported_activities \\ Activities.get_all_default_activities()
      )
      when is_bitstring(username) and type in @highscore_types do
    case Ratelimit.check_ratelimit(ratelimit, type) do
      {:ok, _} ->
        case create_url(type, username) |> get() do
          {:ok, %Tesla.Env{body: body, status: 200}} ->
            PlayerHighscores.new_from_bitstring(username, type, body, supported_activities)

          {:ok, %Tesla.Env{status: 404, headers: headers}} ->
            {:error,
             Error.new(
               :http_error,
               "404 not found (username: #{username}, type: #{type})",
               HttpErrorMetadata.new(
                 404,
                 "404 not found (username: #{username}, type: #{type})",
                 headers,
                 type
               )
             )}

          {:ok, %Tesla.Env{status: status, headers: headers}} when status in [428, 500, 504] ->
            {:error,
             Error.new(
               :http_error,
               "Service offline or ratelimiter has kicked in",
               HttpErrorMetadata.new(
                 status,
                 "Service offline or ratelimiter has kicked in",
                 headers,
                 type
               )
             )}

          {:ok, %Tesla.Env{status: status, headers: headers}} ->
            {:error,
             Error.new(
               :http_error,
               "Unsupported API response",
               HttpErrorMetadata.new(
                 status,
                 "Unsupported API response",
                 headers,
                 type
               )
             )}

          {:error, error} ->
            {:error,
             Error.new(
               :http_error,
               error,
               HttpErrorMetadata.new(
                 nil,
                 error,
                 [],
                 type
               )
             )}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Get multiple player highscores by player username list and highscore type
  """
  @spec get_multiple_highscores(
          list(String.t()),
          highscore_type(),
          Ratelimit.t(),
          list(String.t())
        ) :: list(PlayerHighscores.t() | {:error, Error.t()})
  def get_multiple_highscores(
        usernames,
        type,
        ratelimit \\ @default_ratelimiter,
        supported_activities \\ Activities.get_all_default_activities()
      )
      when is_list(usernames) and type in @highscore_types do
    tasks =
      usernames
      |> Enum.uniq()
      |> Enum.map(fn username ->
        Task.async(fn -> get_highscores(username, type, ratelimit, supported_activities) end)
      end)

    Task.yield_many(tasks, 30000)
    |> Enum.map(fn {task, result} ->
      case result do
        nil ->
          Task.shutdown(task, :brutal_kill)
          Error.new(:task_error, "Task timed out")

        {:exit, reason} ->
          Error.new(:task_error, reason)

        {:ok, result} ->
          result
      end
    end)
  end

  @doc """
  Get multiple player highscores by player username and every highscore type
  """
  @spec get_all_highscores(String.t(), Ratelimit.t(), list(String.t())) ::
          list({:ok, PlayerHighscores.t()} | {:error, Error.t()})
  def get_all_highscores(
        username,
        ratelimit \\ @default_ratelimiter,
        supported_activities \\ Activities.get_all_default_activities()
      )
      when is_bitstring(username) do
    tasks =
      @highscore_types
      |> Enum.map(fn type ->
        Task.async(fn -> get_highscores(username, type, ratelimit, supported_activities) end)
      end)

    Task.yield_many(tasks, 30_000)
    |> Enum.map(fn {task, result} ->
      case result do
        nil ->
          Task.shutdown(task, :brutal_kill)
          Error.new(:task_error, "Task timed out")

        {:exit, reason} ->
          Error.new(:task_error, reason)

        {:ok, result} ->
          result
      end
    end)
  end

  @doc """
  Get multiple player highscores by player username list and every highscore type
  """
  @spec get_multiple_all_highscores(list(String.t()), Ratelimit.t(), list(String.t())) ::
          list(PlayerHighscores.t() | {:error, Error.t()})
  def get_multiple_all_highscores(
        usernames,
        ratelimit \\ @default_ratelimiter,
        supported_activities \\ Activities.get_all_default_activities()
      )
      when is_list(usernames) do
    tasks =
      usernames
      |> Enum.uniq()
      |> Enum.map(fn username ->
        Task.async(fn -> get_all_highscores(username, ratelimit, supported_activities) end)
      end)

    Task.yield_many(tasks, 30_000)
    |> Enum.flat_map(fn {task, result} ->
      case result do
        nil ->
          Task.shutdown(task, :brutal_kill)
          Error.new(:task_error, "Task timed out")

        {:exit, reason} ->
          Error.new(:task_error, reason)

        {:ok, result} ->
          result
      end
    end)
  end

  @doc """
  Get player highscores by `ExOsrsApi.PlayerRequest` type
  """
  @spec get_player_request(ExOsrsApi.PlayerRequest.t(), Ratelimit.t(), list(String.t())) ::
          list(PlayerHighscores.t() | {:error, Error.t()})
  def get_player_request(
        %PlayerRequest{username: username, types: types},
        ratelimit \\ @default_ratelimiter,
        supported_activities \\ Activities.get_all_default_activities()
      ) do
    tasks =
      types
      |> Enum.map(fn type ->
        Task.async(fn -> get_highscores(username, type, ratelimit, supported_activities) end)
      end)

    Task.yield_many(tasks, 30_000)
    |> Enum.map(fn {task, result} ->
      case result do
        nil ->
          Task.shutdown(task, :brutal_kill)
          Error.new(:task_error, "Task timed out")

        {:exit, reason} ->
          Error.new(:task_error, reason)

        {:ok, result} ->
          result
      end
    end)
  end

  @doc """
  Get multiple player highscores by `ExOsrsApi.PlayerRequest` type
  """
  @spec get_multiple_player_request(list(PlayerRequest.t()), Ratelimit.t(), list(String.t())) ::
          list(PlayerHighscores.t() | {:error, Error.t()})
  def get_multiple_player_request(
        player_requests,
        ratelimit \\ @default_ratelimiter,
        supported_activities \\ Activities.get_all_default_activities()
      )
      when is_list(player_requests) do
    tasks =
      player_requests
      |> Enum.uniq()
      |> Enum.map(fn player_request ->
        Task.async(fn -> get_player_request(player_request, ratelimit, supported_activities) end)
      end)

    Task.yield_many(tasks, 30_000)
    |> Enum.flat_map(fn {task, result} ->
      case result do
        nil ->
          Task.shutdown(task, :brutal_kill)
          Error.new(:task_error, "Task timed out")

        {:exit, reason} ->
          Error.new(:task_error, reason)

        {:ok, result} ->
          result
      end
    end)
  end

  @spec create_url(
          highscore_type(),
          String.t()
        ) :: String.t()
  defp create_url(type, username) when is_atom(type) and is_bitstring(username) do
    "m=#{type_transform(type)}/index_lite.ws?player=#{username}"
  end

  @spec type_transform(highscore_type()) :: String.t()
  defp type_transform(type) when is_atom(type) do
    case type do
      :regular -> "hiscore_oldschool"
      :ironman -> "hiscore_oldschool_ironman"
      :hardcore_ironman -> "hiscore_oldschool_hardcore_ironman"
      :ultimate_ironman -> "hiscore_oldschool_ultimate"
      :deadman -> "hiscore_oldschool_deadman"
      :seasonal -> "hiscore_oldschool_seasonal"
      :tournament -> "hiscore_oldschool_tournament"
    end
  end
end
