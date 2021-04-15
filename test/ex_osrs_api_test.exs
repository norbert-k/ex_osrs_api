defmodule ExOsrsApiTest do
  use ExUnit.Case
  doctest ExOsrsApi

  test "greets the world" do
    assert ExOsrsApi.hello() == :world
  end
end
