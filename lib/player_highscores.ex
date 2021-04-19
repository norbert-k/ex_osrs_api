defmodule ExOsrsApi.PlayerHighscores do
  @moduledoc """
  ### PlayerHighscores
  Holds PlayerHighscores `skills` and `activities` data
  """
  alias ExOsrsApi.Models.Skills
  alias ExOsrsApi.Models.Activities
  alias ExOsrsApi.Errors.Error

  @enforce_keys [:username, :type, :skills, :activities, :empty]
  defstruct [:username, :type, :skills, :activities, :empty]

  @type t() :: %__MODULE__{
          type: atom(),
          skills: Skills.t() | nil,
          activities: Activities.t() | nil
        }

  @spec new_empty(String.t(), atom) :: {:ok, t()}
  def new_empty(username, type) when is_atom(type) do
    {:ok,
     %__MODULE__{
       username: username,
       type: type,
       skills: nil,
       activities: nil,
       empty: true
     }}
  end

  @doc """
  Creates new `%ExOsrsApi.PlayerHighscores{}` from "CSV" like string

  You can supply your own activity list by specifying last argument with your own list of activities (list of strings)
  """
  @spec new_from_bitstring(String.t(), atom(), String.t(), list(String.t())) ::
          {:error, Error.t()} | {:ok, t()}
  def new_from_bitstring(
        username,
        type,
        data,
        supported_activities \\ Activities.get_all_default_activities()
      )
      when is_bitstring(username) and is_bitstring(data) do
    {skills, activities} =
      data
      |> String.split("\n", trim: true)
      |> Enum.split(Skills.skill_length())

    with {:ok, skills} <- skills |> Skills.new_from_bitstring(),
         {:ok, activities} <- activities |> Activities.new_from_bitstring(supported_activities) do
      {:ok,
       %__MODULE__{
         username: username,
         type: type,
         skills: skills,
         activities: activities,
         empty: false
       }}
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Check if `PlayerHighscores` data is empty
  """
  @spec is_empty?(t()) :: boolean()
  def is_empty?(%__MODULE__{empty: empty}) do
    empty
  end

  @doc """
  Get `PlayerHighscores` skills data
  """
  @spec get_skills(t()) :: Skills.t() | nil
  def get_skills(%__MODULE__{skills: skills}) do
    skills
  end

  @doc """
  Get `PlayerHighscores` activities data
  """
  @spec get_activities(t()) :: Activities.t() | nil
  def get_activities(%__MODULE__{activities: activities}) do
    activities
  end

  @doc """
  Get `PlayerHighscores` specific skill data by skill name (atom)
  """
  @spec get_skill_data(t(), atom) ::
          {:error, Error.t()} | {:ok, ExOsrsApi.Models.SkillEntry.t()}
  def get_skill_data(%__MODULE__{skills: %Skills{} = skills}, skill) when is_atom(skill) do
    Skills.get_skill_data(skills, skill)
  end

  @doc """
  Get `PlayerHighscores` specific activity data by activity name (string)
  """
  @spec get_activity_data(t(), binary) ::
          {:error, Error.t()} | {:ok, ExOsrsApi.Models.ActivityEntry.t()}
  def get_activity_data(%__MODULE__{activities: activities}, activity)
      when is_bitstring(activity) do
    Activities.get_activity_data(activities, activity)
  end

  @doc """
  Get `PlayerHighscores` non nil skills data
  """
  @spec get_non_nil_skills(t()) :: list(ExOsrsApi.Models.SkillEntry.t())
  def get_non_nil_skills(%__MODULE__{skills: skills}) do
    skills.data
    |> Enum.filter(fn x -> x.rank != nil end)
  end

  @doc """
  Get `PlayerHighscores` non nil activities data
  """
  @spec get_non_nil_activities(t()) :: list(ExOsrsApi.Models.ActivityEntry.t())
  def get_non_nil_activities(%__MODULE__{activities: activities}) do
    activities.data
    |> Enum.filter(fn x -> x.rank != nil end)
  end
end
