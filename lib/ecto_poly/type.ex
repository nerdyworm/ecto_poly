defmodule EctoPoly.Type do
  use Ecto.Type
  import EctoPoly.Util

  @type_field :__type__

  def type, do: :map

  def cast(%{"__type__" => type} = map) do
    type =
      type
      |> String.to_atom()

    {:ok,
     type
     |> struct()
     |> type.changeset(map)
     |> Ecto.Changeset.apply_changes()}
  end

  def cast(%{__type__: type} = map) do
    type =
      type
      |> String.to_atom()

    {:ok,
     type
     |> struct()
     |> type.changeset(map)
     |> Ecto.Changeset.apply_changes()}
  end

  def cast(%Ecto.Changeset{} = changeset) do
    {:ok,
     changeset
     |> Ecto.Changeset.apply_changes()}
  end

  def cast(%{:__struct__ => _type} = map) do
    {:ok, map}
  end

  def cast(%{} = map) do
    {:ok, map}
  end

  def load(%{"__type__" => module} = data) when is_map(data) do
    module
    |> String.to_existing_atom()
    |> load(data)
  end

  def load(data) when is_binary(data) do
    case Jason.decode(data) do
      {:ok, map} ->
        load(map)

      {:error, error} ->
        {:error, error}
    end
  end

  def load(%{} = data) when is_map(data) do
    {:ok, data}
  end

  def dump(%Ecto.Changeset{} = data) do
    data = Ecto.Changeset.apply_changes(data)
    dump(data)
  end

  def dump(%{:__struct__ => module} = data) do
    result = Ecto.embedded_dump(data, :json)
    result = result |> Map.put(@type_field, Atom.to_string(module))
    {:ok, result}
  end

  def dump_value(type, value) do
    with {:ok, value} <- Ecto.Type.dump(type, value, &dump_value/2),
         {:ok, value} <- transform_dump(type, value) do
      {:ok, value}
    else
      {:error, error} ->
        {:error, error}

      :error ->
        :error
    end
  end

  defp transform_dump(type, value), do: do_transform_dump(Ecto.Type.type(type), value)
  defp do_transform_dump(_, nil), do: {:ok, nil}
  defp do_transform_dump(:decimal, value), do: {:ok, Decimal.to_string(value)}

  defp do_transform_dump(:time, %Time{} = t), do: {:ok, t}

  defp do_transform_dump(:time_usec, %Time{} = t), do: {:ok, t}

  defp do_transform_dump(:naive_datetime, %NaiveDateTime{} = dt), do: {:ok, dt}

  defp do_transform_dump(:naive_datetime_usec, %NaiveDateTime{} = dt), do: {:ok, dt}

  defp do_transform_dump(:utc_datetime, %DateTime{} = dt), do: {:ok, dt}

  defp do_transform_dump(:utc_datetime_usec, %DateTime{} = dt), do: {:ok, dt}

  defp do_transform_dump(:date, %Date{} = d), do: {:ok, d}

  defp do_transform_dump({:embed, %{cardinality: :many}}, value) do
    {:ok, Enum.map(value, &struct_to_map/1)}
  end

  defp do_transform_dump({:embed, %{cardinality: :one}}, value) do
    {:ok, struct_to_map(value)}
  end

  defp do_transform_dump(_type, value) do
    {:ok, value}
  end

  def load(schema, data) do
    {:ok, Ecto.embedded_load(schema, data, :json)}
  end
end
