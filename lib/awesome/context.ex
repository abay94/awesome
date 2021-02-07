defmodule Awesome.Context do

  import Ecto.Query, warn: false
  alias Awesome.Repo

  alias Awesome.Context.Group



  def list_groups(params) do
    IO.inspect params
    min_stars =
      case params["min_stars"] do
        nil -> 0
        cnt ->
          case Integer.parse(cnt) do
            :error -> 0
            {got_cnt,_} -> got_cnt
          end
      end
    query =
      from g in Group,
      join: l in assoc(g, :lib),
      where: l.cnt_star > ^min_stars,
      preload: [lib: l]

    Repo.all(query)
  end


end