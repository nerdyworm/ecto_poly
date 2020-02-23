# EctoPoly

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_poly` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_poly, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_poly](https://hexdocs.pm/ecto_poly).

```elixir
defmodule Example do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoPoly

  schema "examples" do
    field(:name, :string)
    embed_poly(:data)
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:name])
    |> cast_poly(:data)
  end
end
```

