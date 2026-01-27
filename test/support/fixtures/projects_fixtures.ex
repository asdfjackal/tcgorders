defmodule TCGOrders.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TCGOrders.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name"
      })

    {:ok, project} = TCGOrders.Projects.create_project(scope, attrs)
    project
  end
end
