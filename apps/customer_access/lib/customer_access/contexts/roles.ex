defmodule CustomerAccess.Roles do
  def list_roles() do
    [
      %{name: "admin"},
      %{name: "user"}
    ]
  end
end
