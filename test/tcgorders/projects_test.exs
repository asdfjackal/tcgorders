defmodule TCGOrders.ProjectsTest do
  use TCGOrders.DataCase

  alias TCGOrders.Projects

  describe "projects" do
    alias TCGOrders.Projects.Project

    import TCGOrders.AccountsFixtures, only: [user_scope_fixture: 0]
    import TCGOrders.ProjectsFixtures

    @invalid_attrs %{name: nil}

    test "list_projects/1 returns all scoped projects" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)
      other_project = project_fixture(other_scope)
      assert Projects.list_projects(scope) == [project]
      assert Projects.list_projects(other_scope) == [other_project]
    end

    test "get_project!/2 returns the project with given id" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      other_scope = user_scope_fixture()
      assert Projects.get_project!(scope, project.id) == project
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(other_scope, project.id) end
    end

    test "create_project/2 with valid data creates a project" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Project{} = project} = Projects.create_project(scope, valid_attrs)
      assert project.name == "some name"
      assert project.user_id == scope.user.id
    end

    test "create_project/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(scope, @invalid_attrs)
    end

    test "update_project/3 with valid data updates the project" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Project{} = project} = Projects.update_project(scope, project, update_attrs)
      assert project.name == "some updated name"
    end

    test "update_project/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)

      assert_raise MatchError, fn ->
        Projects.update_project(other_scope, project, %{})
      end
    end

    test "update_project/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(scope, project, @invalid_attrs)
      assert project == Projects.get_project!(scope, project.id)
    end

    test "delete_project/2 deletes the project" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert {:ok, %Project{}} = Projects.delete_project(scope, project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(scope, project.id) end
    end

    test "delete_project/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      project = project_fixture(scope)
      assert_raise MatchError, fn -> Projects.delete_project(other_scope, project) end
    end

    test "change_project/2 returns a project changeset" do
      scope = user_scope_fixture()
      project = project_fixture(scope)
      assert %Ecto.Changeset{} = Projects.change_project(scope, project)
    end
  end
end
