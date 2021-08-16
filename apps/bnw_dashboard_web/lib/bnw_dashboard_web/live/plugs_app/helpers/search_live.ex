defmodule BnwDashboardWeb.PlugsApp.Helpers.SearchLive do
  use BnwDashboardWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def convert_args(args) do
    args
      |> Enum.reject(fn x ->
        %{type: type} = x
        type == :filler
      end)
      |> Enum.map(fn x ->
        %{display_name: display_name, name: name} = x
        [key: display_name, value: name]
      end)
  end

  def get_selected_type(args, selected) do
    %{type: type, special: special} = Enum.find(args, fn x->
      %{name: name} = x
      name == selected
    end)

    cond do
      special == :drop_down ->
        special
      true -> type
    end
  end

  def drop_down_fields(args, selected) do
    %{list: list} = Enum.find(args, fn x->
      %{name: name} = x
      name == selected
    end)

    list = [[key: "Select an Item", value: ""]] ++ list
    list
  end

  def get_step(args, selected) do
    %{step: step} = Enum.find(args, fn x->
      %{name: name} = x
      name == selected
    end)
    step
  end
end
