# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BorrowingBase.Repo.insert!(%BorrowingBase.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias BorrowingBase.{
  Repo,
  Role
}

if (Repo.get_by(Role, name: "App Admin") |> is_nil()) do
  Repo.insert! %Role{
    name: "App Admin",
    app_admin: true
  }
end
