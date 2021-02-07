defmodule AwesomeWeb.GroupController do
  use AwesomeWeb, :controller

  alias Awesome.Context

  def index(conn, params) do
    groups = Context.list_groups(params)
    render(conn, "index.html", groups: groups)
  end

end
