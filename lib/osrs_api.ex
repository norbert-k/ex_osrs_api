defmodule ExOsrsApi.OsrsApi do
  use Tesla, only: ~w(get)a, docs: false

  alias ExOsrsApi.Ratelimit
  alias ExOsrsApi.PlayerHighscores
  alias ExOsrsApi.Errors.Error
  alias ExOsrsApi.Errors.HttpErrorMetadata

  @highscore_types ~w(regular ironman hardcore_ironman ultimate_ironman deadman seasonal tournament)a

  adapter(Tesla.Adapter.Hackney)

  plug(Tesla.Middleware.Timeout, timeout: 19_000)
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

  @spec get_highscores(
          String.t(),
          :deadman
          | :hardcore_ironman
          | :ironman
          | :regular
          | :seasonal
          | :tournament
          | :ultimate_ironman,
          Ratelimit.t()
        ) :: {:error, Error.t()} | {:ok, PlayerHighscores.t()}
  def get_highscores(username, type, ratelimit \\ Ratelimit.new_default())
      when is_bitstring(username) and type in @highscore_types do
    case Ratelimit.check_ratelimit(ratelimit, type) do
      {:ok, _} ->
        case create_url(type, username) |> get() do
          {:ok, %Tesla.Env{body: body, status: 200}} ->
            PlayerHighscores.new_from_bitstring(username, type, body)

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
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_multiple_highscores(
          list(String.t()),
          :deadman
          | :hardcore_ironman
          | :ironman
          | :regular
          | :seasonal
          | :tournament
          | :ultimate_ironman,
          Ratelimit.t()
        ) :: list(PlayerHighscores.t() | {:error, Error.t()})
  def get_multiple_highscores(usernames, type, ratelimit \\ Ratelimit.new_default())
      when is_list(usernames) and type in @highscore_types do
    tasks =
      usernames
      |> Enum.uniq()
      |> Enum.map(fn username ->
        Task.async(fn -> get_highscores(username, type, ratelimit) end)
      end)

    Task.yield_many(tasks)
    |> Enum.map(fn {task, result} ->
      case result do
        nil ->
          Task.shutdown(task, :brutal_kill)
          {:error, "Timed out"}

        {:exit, reason} ->
          {:error, reason}

        {:ok, result} ->
          result
      end
    end)
  end

  @spec get_all_highscores(String.t(), Ratelimit.t()) ::
          list({:ok, PlayerHighscores.t()} | {:error, Error.t()})
  def get_all_highscores(username, ratelimit \\ Ratelimit.new_default())
      when is_bitstring(username) do
    tasks =
      @highscore_types
      |> Enum.map(fn type ->
        Task.async(fn -> get_highscores(username, type, ratelimit) end)
      end)

    Task.yield_many(tasks)
    |> Enum.map(fn {task, result} ->
      case result do
        nil ->
          Task.shutdown(task, :brutal_kill)
          {:error, "Timeout"}

        {:exit, reason} ->
          {:error, reason}

        {:ok, result} ->
          result
      end
    end)
  end

  @spec get_multiple_all_highscores(list(String.t()), Ratelimit.t()) ::
          list(list(PlayerHighscores.t()) | {:error, Error.t()})
  def get_multiple_all_highscores(usernames, ratelimit \\ Ratelimit.new_default())
      when is_list(usernames) do
    tasks =
      usernames
      |> Enum.uniq()
      |> Enum.map(fn username ->
        Task.async(fn -> get_all_highscores(username, ratelimit) end)
      end)

    Task.yield_many(tasks, 20_000)
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

  @spec create_url(
          :deadman
          | :hardcore_ironman
          | :ironman
          | :regular
          | :seasonal
          | :tournament
          | :ultimate_ironman,
          String.t()
        ) :: String.t()
  defp create_url(type, username) when is_atom(type) and is_bitstring(username) do
    "m=#{type_transform(type)}/index_lite.ws?player=#{username}"
  end

  @spec type_transform(
          :deadman
          | :hardcore_ironman
          | :ironman
          | :regular
          | :seasonal
          | :tournament
          | :ultimate_ironman
        ) :: String.t()
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
