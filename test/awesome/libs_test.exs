defmodule Awesome.LibsTest do
  use Awesome.DataCase

  alias Awesome.Libs

  describe "groups" do
    alias Awesome.Libs.Group

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def group_fixture(attrs \\ %{}) do
      {:ok, group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Libs.create_group()

      group
    end

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Libs.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Libs.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      assert {:ok, %Group{} = group} = Libs.create_group(@valid_attrs)
      assert group.name == "some name"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Libs.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      assert {:ok, %Group{} = group} = Libs.update_group(group, @update_attrs)
      assert group.name == "some updated name"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Libs.update_group(group, @invalid_attrs)
      assert group == Libs.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Libs.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Libs.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Libs.change_group(group)
    end
  end
end
