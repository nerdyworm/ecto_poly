defmodule EctoPolyTest do
  use EctoPoly.TestCase

  doctest EctoPoly
  import ExUnit.CaptureLog

  defmodule P do
    use Ecto.Schema
    import Ecto.Changeset
    import EctoPoly

    embedded_schema do
      embed_poly(:data)
    end

    @doc false
    def changeset(config, attrs) do
      config
      |> cast(attrs, [])
      |> cast_poly(:data)
    end
  end

  test "basic string maps" do
    {:ok, p} =
      %P{}
      |> P.changeset(%{"data" => %{"name" => "testing", "__type__" => Thing1 |> to_string}})
      |> Ecto.Changeset.apply_action(:insert)

    assert p.data.name == "testing"

    {:error, changeset} =
      %P{}
      |> P.changeset(%{"data" => %{"endpoint" => "https://", "__type__" => Thing2 |> to_string}})
      |> Ecto.Changeset.apply_action(:insert)

    assert %{name: ["can't be blank"]} = errors_on(changeset).data
  end

  test "basic atom maps" do
    {:ok, p} =
      %P{}
      |> P.changeset(%{data: %{name: "testing", __type__: Thing1 |> to_string}})
      |> Ecto.Changeset.apply_action(:insert)

    assert p.data.name == "testing"
  end

  test "basic struct types" do
    {:ok, p} =
      %P{}
      |> P.changeset(%{"data" => %Thing1{name: "testing"}})
      |> Ecto.Changeset.apply_action(:insert)

    assert p.data.name == "testing"

    {:error, changeset} =
      %P{}
      |> P.changeset(%{"data" => %Thing1{name: ""}})
      |> Ecto.Changeset.apply_action(:insert)

    assert %{name: ["can't be blank"]} = errors_on(changeset).data
  end

  test "empty changes with no validations" do
    {:ok, config} =
      %P{}
      |> P.changeset(%{
        "data" => %{"__type__" => "Elixir.Anything"}
      })
      |> Ecto.Changeset.apply_action(:insert)

    assert config.data.name == nil

    {:ok, config} =
      config
      |> P.changeset(%{
        "data" => %{"__type__" => "Elixir.Anything", "name" => "updated"}
      })
      |> Ecto.Changeset.apply_action(:update)

    assert config.data.name == "updated"
  end

  test "changing types" do
    {:ok, config} =
      %P{}
      |> P.changeset(%{
        "data" => %{"__type__" => "Elixir.Anything", "name" => "anything"}
      })
      |> Ecto.Changeset.apply_action(:insert)

    assert config.data == %Anything{name: "anything"}

    {:ok, config} =
      config
      |> P.changeset(%{
        "data" => %{"__type__" => "Elixir.Cupcake", "frosting" => "chocolate"}
      })
      |> Ecto.Changeset.apply_action(:update)

    assert config.data == %Cupcake{frosting: "chocolate"}
  end

  test "missing" do
    {:ok, config} =
      %P{}
      |> P.changeset(%{"data" => nil})
      |> Ecto.Changeset.apply_action(:insert)

    assert config.data == nil
  end

  test "missing __type__" do
    fun = fn ->
      {:error, changeset} =
        %P{}
        |> P.changeset(%{"data" => %{nothing: true}})
        |> Ecto.Changeset.apply_action(:insert)

      assert %{data: ["Could not find a field type for: %{nothing: true}"]} = errors_on(changeset)
    end

    assert capture_log(fun) =~ "Could not find a field type for:"
  end

  test "insert - missin" do
    {:ok, config} =
      %Thing{}
      |> Thing.changeset(%{"data" => nil})
      |> Repo.insert()

    assert config.data == nil
  end

  test "insert - basic string maps" do
    {:ok, p} =
      %Thing{}
      |> Thing.changeset(%{"data" => %{"name" => "testing", "__type__" => Thing1 |> to_string}})
      |> Repo.insert()

    assert p.data.name == "testing"

    {:error, changeset} =
      %Thing{}
      |> Thing.changeset(%{
        "data" => %{"endpoint" => "https://", "__type__" => Thing2 |> to_string}
      })
      |> Repo.insert()

    assert %{name: ["can't be blank"]} = errors_on(changeset).data
  end

  test "insert - empty map" do
    {:ok, p} =
      %Thing{}
      |> Thing.changeset(%{"data" => %{}})
      |> Repo.insert()

    assert p.data == %EctoPoly.Empty{}
  end

  test "insert - nested maps" do
    {:ok, p} =
      %Thing{}
      |> Thing.changeset(%{
        "data" => %{
          "__type__" => Nested |> to_string,
          "cupcake" => %{"frosting" => "yes please"},
          "things" => [%{"name" => "Thing 1"}, %{"name" => "Thing 2"}]
        }
      })
      |> Repo.insert()

    assert p.data == %Nested{
             cupcake: %Cupcake{frosting: "yes please"},
             things: [%Anything{name: "Thing 1"}, %Anything{name: "Thing 2"}]
           }

    found = Repo.get(Thing, p.id)

    assert found.data == %Nested{
             cupcake: %Cupcake{frosting: "yes please"},
             things: [%Anything{name: "Thing 1"}, %Anything{name: "Thing 2"}]
           }
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
