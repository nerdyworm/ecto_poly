defmodule EctoPoly.Util do
  def struct_to_map(%{:__struct__ => kind} = data) do
    data
    |> Map.delete(:__struct__)
    |> Map.delete(:__meta__)
    |> Map.put(:__type__, to_string(kind))
    |> Enum.map(fn
      {key, value} when is_list(value) ->
        {to_string(key), Enum.map(value, &struct_to_map/1)}

      {key, value} when is_map(value) ->
        {to_string(key), struct_to_map(value)}

      {key, value} ->
        {to_string(key), value}
    end)
    |> Enum.into(%{})
  end

  def struct_to_map(data) when is_map(data) do
    data
    |> Enum.map(fn
      {key, value} when is_map(value) ->
        {to_string(key), struct_to_map(value)}

      {key, value} ->
        {to_string(key), value}
    end)
    |> Enum.into(%{})
  end
end
