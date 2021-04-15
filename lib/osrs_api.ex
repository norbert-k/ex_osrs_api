defmodule ExOsrsApi.OsrsApi do
  use Tesla, only: ~w(get)a, docs: false
  alias ExOsrsApi.PlayerHighscores

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

  @spec check_ratelimit(atom(), integer(), integer()) :: {:ok, integer()} | {:error, String.t()}
  defp check_ratelimit(type, timeout, limit)
       when is_atom(type) and is_integer(timeout) and is_integer(limit) do
    case ExRated.check_rate("osrs-api-rate-limit-" <> Atom.to_string(type), timeout, limit) do
      {:ok, value} -> {:ok, value}
      {:error, limit} -> {:error, "Over the rate limit (max limit: #{limit})"}
    end
  end

  @spec get_highscores(
          String.t(),
          :deadman
          | :hardcore_ironman
          | :ironman
          | :regular
          | :seasonal
          | :tournament
          | :ultimate_ironman,
          non_neg_integer(),
          non_neg_integer()
        ) :: {:error, String.t()} | {:ok, PlayerHighscores.t()}
  def get_highscores(username, type, timeout \\ 60_000, limit \\ 60)
      when is_bitstring(username) and type in @highscore_types do
    case check_ratelimit(type, timeout, limit) do
      {:ok, _} ->
        case create_url(type, username) |> get() do
          {:ok, %Tesla.Env{body: body, status: 200}} ->
            PlayerHighscores.new_from_bitstring(username, type, body)

          {:ok, %Tesla.Env{status: 404}} ->
            {:error, "Not found (username: #{username}, type: #{type})"}

          {:ok, %Tesla.Env{status: status}} when status in [428, 500, 504] ->
            {:error, "Server error (jagex API offline or ratelimit has kicked in)"}

          {:ok, _} ->
            {:error, "Un-supported operation"}

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
          non_neg_integer(),
          non_neg_integer()
        ) :: list(PlayerHighscores.t() | {:error, String.t()})
  def get_multiple_highscores(usernames, type, timeout \\ 60_000, limit \\ 60)
      when is_list(usernames) and type in @highscore_types do
    tasks =
      usernames
      |> Enum.uniq()
      |> Enum.map(fn username ->
        Task.async(fn -> get_highscores(username, type, timeout, limit) end)
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

  @spec get_all_highscores(String.t(), non_neg_integer(), non_neg_integer()) ::
          list({:ok, PlayerHighscores.t()} | {:error, String.t()})
  def get_all_highscores(username, timeout \\ 60_000, limit \\ 60) when is_bitstring(username) do
    tasks =
      @highscore_types
      |> Enum.map(fn type ->
        Task.async(fn -> get_highscores(username, type, timeout, limit) end)
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

  @spec get_multiple_all_highscores(list(String.t()), non_neg_integer(), non_neg_integer()) ::
          list(list(PlayerHighscores.t()) | {:error, String.t()})
  def get_multiple_all_highscores(usernames, timeout \\ 60_000, limit \\ 60)
      when is_list(usernames) do
    tasks =
      usernames
      |> Enum.uniq()
      |> Enum.map(fn username ->
        Task.async(fn -> get_all_highscores(username, timeout, limit) end)
      end)

    Task.yield_many(tasks, 20_000)
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

  @spec create_url(atom(), String.t()) :: String.t()
  defp create_url(type, username) when is_atom(type) and is_bitstring(username) do
    "m=#{type_transform(type)}/index_lite.ws?player=#{username}"
  end

  @spec type_transform(atom()) :: String.t()
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
