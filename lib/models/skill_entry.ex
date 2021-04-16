defmodule ExOsrsApi.Models.SkillEntry do
  @moduledoc """
  ### SkillEntry
  Represents Highscore skill data (attack, defence, strength etc..) entry
  """
  @enforce_keys [:skill, :rank, :level, :empty]
  defstruct [:skill, :rank, :level, :experience, :empty]

  alias ExOsrsApi.Errors.Error
  alias ExOsrsApi.Errors.ParsingErrorMetadata

  @type t() :: %__MODULE__{
          skill: atom(),
          rank: 1..2_000_000 | nil,
          level: 0..99 | nil,
          experience: 0..200_000_000 | nil,
          empty: boolean()
        }

  @doc """
  Check if SkillEntry is empty
  """
  @spec is_empty?(t()) :: boolean()
  def is_empty?(%__MODULE__{empty: empty}) do
    empty
  end

  @doc """
  Creates new `%ExOsrsApi.Models.SkillEntry{}` from "CSV" like string seperated by commas ","
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
