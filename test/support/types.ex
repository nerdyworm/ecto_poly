defmodule Anything do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:name, :string)
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:name])
    |> validate_required([])
  end
end

defmodule Thing do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoPoly

  schema "things" do
    embed_poly(:data)
    embed_poly(:meta)
    timestamps()
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [])
    |> cast_poly(:data)
    |> cast_poly(:meta)
  end
end

defmodule Thing1 do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:name, :string)
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

defmodule Thing2 do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:name, :string)
    field(:endpoint, :string)
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:endpoint, :name])
    |> validate_required([:endpoint, :name])
  end
end

defmodule Cupcake do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:frosting, :string)
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [:frosting])
    |> validate_required([:frosting])
  end
end

defmodule Nested do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_one(:cupcake, Cupcake)
    embeds_many(:things, Anything)
  end

  @doc false
  def changeset(config, attrs) do
    config
    |> cast(attrs, [])
    |> cast_embed(:cupcake)
    |> cast_embed(:things)
  end
end
