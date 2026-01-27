defmodule TCGOrders.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias TCGOrders.Repo

  alias TCGOrders.Projects.Project
  alias TCGOrders.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any project changes.

  The broadcasted messages match the pattern:

    * {:created, %Project{}}
    * {:updated, %Project{}}
    * {:deleted, %Project{}}

  """
  def subscribe_projects(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(TCGOrders.PubSub, "user:#{key}:projects")
  end

  defp broadcast_project(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(TCGOrders.PubSub, "user:#{key}:projects", message)
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects(scope)
      [%Project{}, ...]

  """
  def list_projects(%Scope{} = scope) do
    Repo.all_by(Project, user_id: scope.user.id)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(scope, 123)
      %Project{}

      iex> get_project!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(%Scope{} = scope, id) do
    Repo.get_by!(Project, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(scope, %{field: value})
      {:ok, %Project{}}

      iex> create_project(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(%Scope{} = scope, attrs) do
    with {:ok, project = %Project{}} <-
           %Project{}
           |> Project.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_project(scope, {:created, project})
      {:ok, project}
    end
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(scope, project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(scope, project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Scope{} = scope, %Project{} = project, attrs) do
    true = project.user_id == scope.user.id

    with {:ok, project = %Project{}} <-
           project
           |> Project.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_project(scope, {:updated, project})
      {:ok, project}
    end
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(scope, project)
      {:ok, %Project{}}

      iex> delete_project(scope, project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Scope{} = scope, %Project{} = project) do
    true = project.user_id == scope.user.id

    with {:ok, project = %Project{}} <-
           Repo.delete(project) do
      broadcast_project(scope, {:deleted, project})
      {:ok, project}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(scope, project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Scope{} = scope, %Project{} = project, attrs \\ %{}) do
    true = project.user_id == scope.user.id

    Project.changeset(project, attrs, scope)
  end
end
