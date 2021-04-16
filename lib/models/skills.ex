defmodule ExOsrsApi.Models.Skills do
  alias ExOsrsApi.Models.SkillEntry
  alias ExOsrsApi.Errors.Error
  alias ExOsrsApi.Errors.ParsingErrorMetadata

  defstruct [:data]

  @type t() :: %__MODULE__{
          data: list(SkillEntry.t())
        }

  @skills ~w(overall attack defence strength hitpoints ranged prayer magic cooking
    woodcutting fletching fishing firemaking crafting smithing mining herblore agility
    thieving slayer farming runecrafting hunter construction)a

  @doc """
  Get all suported skills
  """
  @spec get_all_skills :: [atom(), ...]
  def get_all_skills() do
    @skills
  end

  @doc """
  Get suported skills list length
  """
  @spec skill_length :: non_neg_integer
  def skill_length() do
    length(@skills)
  end

  @doc """
  Creates new `%ExOsrsApi.Models.Skills{}` from "CSV" like string seperated by newlines `"\n"`
  """
  @spec new_from_bitstring(list(String.t())) ::
          {:error, Error.t()} | {:ok, t()}
  def new_from_bitstring(data) when is_list(data) do
    skill_data =
      data
      |> Enum.with_index()
      |> Enum.reduce_while({:ok, []}, fn {value, index}, {:ok, acc} ->
        case SkillEntry.new_from_line(Enum.at(@skills, index), value) do
          {:ok, entry} -> {:cont, {:ok, [entry | acc]}}
          {:error, error} -> {:halt, {:error, error}}
        end
      end)

    case skill_data do
      {:ok, data} ->
        if length(data) == length(@skills) do
          {:ok,
           %__MODULE__{
             data: data |> Enum.reverse()
           }}
        else
          {:error,
           Error.new(
             :parsing_error,
             "Failed to parse skills (invalid length)",
             ParsingErrorMetadata.new("skills", "Failed to parse skills (invalid length)")
           )}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_skill_data(t(), atom()) ::
          {:error, Error.t()} | {:ok, SkillEntry.t()}
  def get_skill_data(%__MODULE__{data: data}, skill) when is_atom(skill) do
    case Enum.find(data, fn %SkillEntry{skill: x} -> x == skill end) do
      nil -> {:error, Error.new(:data_access_error, "Skill (#{skill}) not found")}
      value -> {:ok, value}
    end
  end
end
