defmodule Repo.Migrations.CreateTestTables do
  use Ecto.Migration

  def change do
    create table("things") do
      add(:data, :jsonb)
      add(:meta, :jsonb)

      timestamps()
    end
  end
end
