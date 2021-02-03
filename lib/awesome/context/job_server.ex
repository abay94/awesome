defmodule Awesome.Context.JobServer do
  use GenServer
  alias Awesome.Context.Lib
  alias Awesome.Context.Group


  @update_time 5000
  @awesome_link "https://github.com/h4cc/awesome-elixir/blob/master/README.md"
  @article_tag_class "markdown-body entry-content container-lg, article"


  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    IO.puts "init"
    Process.send_after(self(), :update_groups, 2000)
    {:ok, []}
  end

## ---  Handle job types -----------
  def handle_info(:update_groups, state) do
    loop_update_groups()
    {:noreply, state}
  end

  def handle_info(:update_libs, state) do
    loop_update_libs()
    {:noreply, state}
  end

  def handle_info(:update_libs_rest, state) do
    loop_update_libs_rest()
    {:noreply, state}
  end

## ---------------------------------

## ------  Run job types -----------
  def handle_cast(:update_groups, _state) do
    {article, group_anchor} = get_all_groups()
    IO.inspect "update_groups"
    Enum.map(group_anchor, fn({group_name, anchor}) ->
      case Awesome.Repo.get_by(Group, %{name: group_name}) do
        nil ->
          Group.changeset(%Group{},%{name: group_name,anchor: anchor})
          |>Awesome.Repo.insert()
        group_got ->
          if (group_got.name == group_name) and (group_got.anchor == anchor) do
            :do_nothing
          else
            group_got
            |>Ecto.Changeset.change(%{name: group_name,anchor: anchor})
            |> Awesome.Repo.update()
          end
      end
    end)
    {:noreply, article}
  end


  def handle_cast(:update_libs, state_article) do
    IO.puts "update_libs"

    {_,parsed_groups_map} = group_all_libs(state_article)   # %{ group1 => [{lib_name1, link1, lib_desc1}, ..] , ..}
    groups = Awesome.Repo.all(Group)

    Enum.map(groups, fn (group)->
          case parsed_groups_map[group.name] do
            {libs, group_desc} ->
              found_group = Awesome.Repo.get_by(Group, name: group.name)

              if found_group.description == group_desc do
                :do_nothing
              else
                found_group
                |> Ecto.Changeset.change(%{description: group_desc})
                |> Awesome.Repo.update()
              end

              Enum.map(libs, fn({lib_name, link, lib_desc})->

                case Awesome.Repo.get_by(Lib, %{name: lib_name}) do
                  nil ->
                    found_group
                    |>Ecto.build_assoc(:lib, %{name: lib_name, link: link, description: lib_desc })
                    |>Awesome.Repo.insert
                  lib_got ->
                    if (lib_got.name == lib_name) and (lib_got.link == link) and (lib_got.description == lib_desc) do
                      :do_nothing
                    else
                      changeset_lib = Ecto.Changeset.change(lib_got, %{link: link, description: lib_desc})

                      found_group
                      |>Ecto.build_assoc(:lib, changeset_lib)
                      |>Awesome.Repo.insert
                    end
                end

              end)
            _ -> :do_nothing
          end
        end)
    {:noreply, :no_state}
  end


  def handle_cast(:update_libs_rest, _) do

    libs = Awesome.Repo.all(Lib)

    Enum.map(libs, fn (lib)->
      case parse_lib_page(lib.link) do
        :error_on_get -> :skip
        {last_com_date, cnt_star} -> {last_com_date, cnt_star}
      end
    end)

    {:noreply, :no_state}
  end


## ---------------------------------

## ------  Trigger jobs   -----------

  def loop_update_groups do
    GenServer.cast(__MODULE__, :update_groups)
    Process.send_after(self(), :update_libs, @update_time)
  end

  def loop_update_libs do
    GenServer.cast(__MODULE__, :update_libs)
    Process.send_after(self(), :update_libs_rest, @update_time)
  end

  def loop_update_libs_rest do
    GenServer.cast(__MODULE__, :update_libs_rest)
    Process.send_after(self(), :update_groups, @update_time)
  end

## ---------------------------------


## ---------- Internal  --------------

def get_all_groups() do
  case HTTPoison.get(@awesome_link) do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
      {:ok, body} = Floki.parse_document(body)
      article = Floki.find(body,@article_tag_class)
      [{_,_,groups1}] = article
      {_,_,[_,{_,_,groups}|_]} = find_first_ul(groups1)
      group_anchor =  Enum.map(groups, fn({_,_,[{_,[{_,anchor}],[group_name]}]})-> {group_name,anchor} end )
      {groups1, group_anchor}
    _ ->
      {[],[]}
  end
end



def find_first_ul([{tag_name, _attributes, children_nodes}|_]) when tag_name == "ul" do
    [group_libs|_] = children_nodes
    group_libs
  end
def find_first_ul([{tag_name, _attributes, _children_nodes}|rest]) when tag_name != "ul" do
    find_first_ul(rest)
end

def find_first_ul(rest) when rest == [] do
  []
end



def group_all_libs(content) do

  Enum.reduce(content, {{:initial_group,:group_desc}, %{} },
      fn
        ({tag_name, _attrs, children_nodes}, {{_group_name, group_desc},res_map}) when tag_name == "h2" ->
          [group_name] = tl(children_nodes)
          {{group_name, group_desc}, res_map}
        ({tag_name, attrs, children_nodes}, {{group_name, _group_desc},res_map}) when tag_name == "p" ->
          group_desc = Floki.raw_html({tag_name, attrs, children_nodes})
          {{group_name, group_desc}, res_map}
        ({tag_name, _attrs, children_nodes}, {{group_name, group_desc},res_map}) when tag_name == "ul" ->
          res_map =
            Map.put(res_map,group_name,
               {for {_,_,[{_,[{_,link}],[lib_name]}|_]}=child <- children_nodes
                  do
                    lib_desc = Floki.raw_html(child)
                    {lib_name, link, lib_desc}
                  end, group_desc})
          {{group_name, group_desc},res_map}
        ({_tag_name, _attrs, _children_nodes}, {{group_name, group_desc},res_map})->
          {{group_name, group_desc},res_map}
      end)

  end

  def parse_lib_page(link) do
    case HTTPoison.get(link) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body} = Floki.parse_document(body)
        :timer.sleep(500)
#        all_date = Floki.find(body,"Box-header Box-header--blue position-relative, div")
        all_date = Floki.find(body,"#files a")
        IO.inspect all_date
        [{_,[{_,date}|_],_}|_] = Floki.find(all_date,"relative-time")
        [{_,_,[cnt_star]}] = Floki.find(body,".js-social-count")
#        {:ok,dt,time_zone} = DateTime.from_iso8601(date)
#        dt_now =  DateTime.now("Etc/UTC")
#        diff_seconds = DateTime.diff(dt_now,dt)
        IO.inspect date
        IO.inspect cnt_star
        {:ok,:ok}

      {:ok, %HTTPoison.Response{status_code: 301, body: body}} ->
        {:ok, body} = Floki.parse_document(body)
        [{_,[{_,redirect}],_}] = Floki.find(body,"a")
        parse_lib_page(redirect)

      other ->
        IO.inspect other
        :error_on_get
    end

  end


end
