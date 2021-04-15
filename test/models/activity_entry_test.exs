defmodule ExOsrsApiTest.Models.ActivityEntry do
  alias ExOsrsApi.Models.ActivityEntry

  use ExUnit.Case
  doctest ExOsrsApi.Models.ActivityEntry

  test "new from line (success)" do
    assert ActivityEntry.new_from_line("Callisto", "30,30") ==
             {:ok,
              %ActivityEntry{
                activity: "Callisto",
                rank: 30,
                actions: 30,
                empty: false
              }}
  end

  test "new from line (empty)" do
    assert ActivityEntry.new_from_line("Callisto", "-1,-1") ==
             {:ok,
              %ActivityEntry{
                activity: "Callisto",
                rank: nil,
                actions: nil,
                empty: true
              }}
  end

  test "new from line (failure)" do
    assert ActivityEntry.new_from_line("Callisto", "abc,abc,cba") ==
             {:error,
              %ExOsrsApi.Errors.Error{
                message: "Failed to parse activity_entry",
                metadata: %ExOsrsApi.Errors.ParsingErrorMetadata{
                  extra_message: "Failed to parse activity_entry",
                  name: "Callisto"
                },
                type: :parsing_error
              }}
  end
end
