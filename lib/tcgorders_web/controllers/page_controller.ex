defmodule TCGOrdersWeb.PageController do
  use TCGOrdersWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
