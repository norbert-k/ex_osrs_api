defmodule ExOsrsApi.Models.SkillEntry do
  @moduledoc """
  ## SkillEntry
  Represents Highscore skill data (attack, defence, strength etc..) entry
  """
  @enforce_keys [:skill, :rank, :level, :empty]
  defstruct [:skill, :rank, :level, :experience, :empty]

  alias ExOsrsApi.Errors.Error
  alias ExOsrsApi.Errors.ParsingErrorMetadata

  @type t() :: %__MODULE__{
          skill: atom(),
          rank: non_neg_integer() | nil,
          level: non_neg_integer() | nil,
          experience: non_neg_integer() | nil,
          empty: boolean()
        }

  @doc """
  Check if `ExOsrsApi.Models.SkillEntry` has no data from OSRS highscore API (if rank is too low OSRS api will return `"-1,-1"` in level and rank fields)

  ## Examples:
      iex(1)> data = %ExOsrsApi.Models.SkillEntry{
        empty: true,
        experience: nil,
        level: nil,
        rank: nil,
        skill: :magic
      }
      iex(2)> ExOsrsApi.Models.SkillEntry.is_empty?(data)
      true

      iex(1)> {:ok, data} = ExOsrsApi.Models.SkillEntry.new_from_line(:attack, "4719223,2,102")
      {:ok,
      %ExOsrsApi.Models.SkillEntry{
        empty: false,
        experience: 102,
        level: 2,
        rank: 4719223,
        skill: :attack
      }}
      iex(2)> ExOsrsApi.Models.SkillEntry.is_empty?(data)
      false
  """
  @spec is_empty?(t()) :: boolean()
  def is_empty?(%__MODULE__{empty: empty}) do
    empty
  end

  @doc """
  Creates new `%ExOsrsApi.Models.SkillEntry{}` from "CSV" like string seperated by commas ","

  ## Examples:

      iex> ExOsrsApi.Models.SkillEntry.new_from_line(:attack, "4719223,2,102")
      {:ok,
      %ExOsrsApi.Models.SkillEntry{
        empty: false,
        experience: 102,
        level: 2,
        rank: 4719223,
        skill: :attack
      }}

      iex> ExOsrsApi.Models.SkillEntry.new_from_line(:defence, "2,102")
      {:error, "Error parsing SkillEntry (skill: defence)"}

      iex>ExOsrsApi.Models.SkillEntry.new_from_line(:defence, "invalid,input")
      {:error, "Error parsing SkillEntry (skill: defence)"}

      iex> ExOsrsApi.Models.SkillEntry.new_from_line(:magic, "-1,-1")
      {:ok,
      %ExOsrsApi.Models.SkillEntry{
        empty: true,
        experience: nil,
        level: nil,
        rank: nil,
        skill: :magic
      }}
  """
  @spec new_from_line(atom(), String.t()) ::
          {:error, Error.t()} | {:ok, t()}
  def new_from_line(skill, line) when is_bitstring(line) do
    case String.split(line, ",", trim: true) do
      [rank, level, experience] ->
        with {rank, _} <- Integer.parse(rank),
             {level, _} <- Integer.parse(level),
             {experience, _} <- Integer.parse(experience) do
          {
            :ok,
            %__MODULE__{
              skill: skill,
              rank: rank,
              level: level,
              experience: experience,
              empty: false
            }
          }
        else
          :error ->
            {:error,
             Error.new(
               :parsing_error,
               "Failed to parse skill_entry",
               ParsingErrorMetadata.new(Atom.to_string(skill), "Failed to parse skill_entry")
             )}
        end

      ["-1", "-1"] ->
        {:ok,
         %__MODULE__{
           skill: skill,
           rank: nil,
           level: nil,
           experience: nil,
           empty: true
         }}

      _ ->
        {:error,
         Error.new(
           :parsing_error,
           "Failed to parse skill_entry",
           ParsingErrorMetadata.new(Atom.to_string(skill), "Failed to parse skill_entry")
         )}
    end
  end
end
