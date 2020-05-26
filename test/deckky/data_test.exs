defmodule Deckky.DataTest do
  use ExUnit.Case

  describe "data" do
    test "load" do
      {:ok, groups} = Deckky.Data.groups("5D70573F-6FAB-459F-AE85-4F5A4B4B6A0C")
      assert length(groups) == 2

      first_group = groups |> Enum.find(nil, fn g -> g["group_id"] == "B6F239DD-8C07-4D04-ACF0-4342B7065C8B" end)
      assert first_group["title"] == "Group test 1"
      assert first_group["cards"] |> length() == 2

      second_group = groups |> Enum.find(nil, fn g -> g["group_id"] == "D3E016B2-4F0B-4EF3-BE75-F5CB1140B185" end)
      assert second_group["title"] == "Group test 2"
      assert second_group["cards"] |> length() == 2
    end
  end
end
