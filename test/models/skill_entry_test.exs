defmodule ExOsrsApiTest.Models.SkillEntry do
  alias ExOsrsApi.Models.SkillEntry

  use ExUnit.Case

  test "new from line (success)" do
    assert SkillEntry.new_from_line(:attack, "30,30,30") ==
             {:ok,
              %SkillEntry{
                skill: :attack,
                rank: 30,
                level: 30,
                experience: 30,
                empty: false
              }}
  end

  test "new from line (empty)" do
    assert SkillEntry.new_from_line(:attack, "-1,-1") ==
             {:ok,
              %SkillEntry{
                skill: :attack,
                rank: nil,
                level: nil,
                empty: true
              }}
  end

  test "new from line (failure)" do
    assert SkillEntry.new_from_line(:attack, "abc,abc,cba") ==
             {:error,
              %ExOsrsApi.Errors.Error{
                message: "Failed to parse skill_entry",
                metadata: %ExOsrsApi.Errors.ParsingErrorMetadata{
                  extra_message: "Failed to parse skill_entry",
                  name: "attack"
                },
                type: :parsing_error
              }}
  end
end
