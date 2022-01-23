defmodule EctoPoly.Changeset do
  require Logger
  import Ecto.Changeset
  import EctoPoly.Util

  def cast(%Ecto.Changeset{params: params} = changeset, field) do
    # ensure that we can cast() the params into the changeset
    types = Map.put(changeset.types, field, EctoPoly.Type)
    changeset = put_in(changeset.types, types)

    changeset
    |> cast(params, [field])
    |> add_embed_type(field)
    |> safe_cast_embed(field)
    |> prepare_changes(&apply_changes(&1, field))
  end

  defp apply_changes(changeset, field) do
    case get_change(changeset, field) do
      %Ecto.Changeset{valid?: true} = valid ->
        valid = Ecto.Changeset.apply_changes(valid)
        changes = Map.put(changeset.changes, field, valid)
        %{changeset | changes: changes}

      _ ->
        changeset
    end
  end

  defp add_embed_type(%Ecto.Changeset{types: types} = changeset, field) do
    kind =
      case get_field(changeset, field) do
        %{"__type__" => type} ->
          String.to_existing_atom(type)

        %{:__type__ => type} ->
          String.to_existing_atom(type)

        %{:__struct__ => type} ->
          type

        _ ->
          EctoPoly.Empty
      end

    type = make_embed(kind, field)
    types = Map.put(types, field, type)
    put_in(changeset.types, types)
  end

  defp make_embed(kind, field) do
    {:embed,
     %Ecto.Embedded{
       cardinality: :one,
       field: field,
       on_cast: fn
         %{:__struct__ => _} = schema, attrs ->
           kind.changeset(schema, attrs)

         schema, attrs when schema == %{} ->
           kind.changeset(struct(kind), attrs)
       end,
       on_replace: :delete,
       related: kind
     }}
  end

  defp safe_cast_embed(%Ecto.Changeset{params: params} = changeset, field) do
    case get_change(changeset, field) do
      %{"__type__" => _kind} ->
        cast_embed(changeset, field)

      %{:__type__ => _kind} ->
        cast_embed(changeset, field)

      %{:__struct__ => _module} = data ->
        data = struct_to_map(data)

        params =
          case params[field] do
            nil ->
              case params[to_string(field)] do
                nil ->
                  params

                _ ->
                  Map.put(params, to_string(field), data)
              end

            _ ->
              Map.put(params, field, data)
          end

        %{changeset | params: params}
        |> cast_embed(field)

      # result = module.changeset(struct(module), data)
      # put_embed(changeset, field, result)

      map when map == %{} ->
        put_change(changeset, field, %{})

      nil ->
        changeset

      other ->
        Logger.error("""
        Could not find a field type for: #{inspect(other)}.  A map with the __type__ key is required or a struct.
        """)

        error =
          %EctoPoly.Empty{}
          |> EctoPoly.Empty.changeset(%{data: other})
          |> Map.put(:valid?, false)

        changeset
        |> add_error(field, "Could not find a field type for: #{inspect(other)}")
        |> put_change(field, error)
    end
  end
end
