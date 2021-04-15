defmodule ExOsrsApi.PlayerHighscores do
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

  @spec new_from_bitstring(String.t(), atom(), String.t()) :: {:error, Error.t()} | {:ok, t()}
  def new_from_bitstring(username, type, data)
      when is_bitstring(username) and is_bitstring(data) do
    {skills, activities} =
      data
      |> String.split("\n", trim: true)
      |> Enum.split(Skills.skill_length())

    with {:ok, skills} <- skills |> Skills.new_from_bitstring(),
         {:ok, activities} <- activities |> Activities.new_from_bitstring() do
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

  @spec is_empty?(t()) :: boolean()
  def is_empty?(%__MODULE__{empty: empty}) do
    empty
  end

  @spec get_skills(t()) :: Skills.t() | nil
  def get_skills(%__MODULE__{skills: skills}) do
    skills
  end

  @spec get_activities(t()) :: Activities.t() | nil
  def get_activities(%__MODULE__{activities: activities}) do
    activities
  end

  @spec get_skill_data(t(), atom) ::
          {:error, Error.t()} | {:ok, ExOsrsApi.Models.SkillEntry.t()}
  def get_skill_data(%__MODULE__{skills: %Skills{} = skills}, skill) when is_atom(skill) do
    Skills.get_skill_data(skills, skill)
  end

  @spec get_activity_data(t(), binary) ::
          {:error, Error.t()} | {:ok, ExOsrsApi.Models.ActivityEntry.t()}
  def get_activity_data(%__MODULE__{activities: activities}, activity)
      when is_bitstring(activity) do
    Activities.get_activity_data(activities, activity)
  end

  @spec get_non_null_skills(t()) :: list(ExOsrsApi.Models.SkillEntry.t())
  def get_non_null_skills(%__MODULE__{skills: skills}) do
    skills.data
    |> Enum.filter(fn x -> x.rank != nil end)
  end

  @spec get_non_null_activities(t()) :: list(ExOsrsApi.Models.ActivityEntry.t())
  def get_non_null_activities(%__MODULE__{activities: activities}) do
    activities.data
    |> Enum.filter(fn x -> x.rank != nil end)
  end
end
