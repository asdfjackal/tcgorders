defmodule TCGOrdersWeb.ItemLive.AssignProject do
  use TCGOrdersWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Add Item to Project
      </.header>
    </Layouts.app>
    """
  end
end
