defmodule Awesome.Context do

  import Ecto.Query, warn: false
  alias Awesome.Repo

  alias Awesome.Context.Group



  def list_groups(params) do
    IO.puts Enum.map_join(params, ", ", fn {key, val} -> ~s{"#{key}", "#{val}"} end)
    Group
    |> Repo.all()
    |> Repo.preload(:lib)
  end


end