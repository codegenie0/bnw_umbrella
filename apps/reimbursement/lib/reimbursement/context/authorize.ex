defmodule Reimbursement.Authorize do
  @moduledoc """
  The Authorization for the OCB plugs app.
  """

  alias Accounts.User
  alias Reimbursement.{
    UserRoles
  }

  @doc """
  This function lists the pages that the current user has access to.
  """
  def list_pages(user, apps) do
    app = Enum.find(apps, &(&1.name == "Reimbursement"))
    role = UserRoles.get_role(user.id)

    if role == "user"
      || role == "report"
      || role == "reviewer"
      || role == "admin" do
      new_pages = []
      new_pages = new_pages ++
      # user has User access
      if UserRoles.get_a_role(user.id, "user") || role == "admin"  do
        [
          Enum.find(app.pages, &(&1.name == "Entries"))
        ]
      else
        []
      end

      # user has Reviewer access
      new_pages = new_pages ++
      if UserRoles.get_a_role(user.id, "reviewer") || role == "admin"  do
        [
          Enum.find(app.pages, &(&1.name == "Review"))
        ]
      else
        []
      end

      # user has Admin access
      new_pages = new_pages ++
      if role == "admin"  do
        [
          Enum.find(app.pages, &(&1.name == "Rates")),
          Enum.find(app.pages, &(&1.name == "Users"))
        ]
      else
        []
      end

      # user has Report access
      new_pages = new_pages ++
      if UserRoles.get_a_role(user.id, "report") || role == "admin"  do
        [
          Enum.find(app.pages, &(&1.name == "Reports"))
        ]
      else
        []
      end

      new_pages = new_pages ++
        [ Enum.find(app.pages, &(&1.name == "Help")) ]

      [Map.put(app, :pages, new_pages)]

    else
      []
    end
  end

  @doc """
  This function check if a user has access to view a page.
  If the users role is admin or it_admin they have complete access.
  Else they only have access to the plugs page.
  """
  def authorize(%User{} = user, page) do
    if UserRoles.get_a_role(user.id, "active") do
      cond do
        user.it_admin || UserRoles.get_a_role(user.id, "admin") -> true
        UserRoles.get_a_role(user.id, "reviewer") && (page == "review"  || page == "help") -> true
        UserRoles.get_a_role(user.id, "report")   && (page == "reports" || page == "help") -> true
        UserRoles.get_a_role(user.id, "user")     && (page == "update"  || page == "help") -> true
        true -> false
      end
    else
      false
    end
  end

  def check_authorization(%User{} = user, page) do
    cond do
      user.it_admin ->
        {:ok, page}
      true ->
        {:error, page}
    end
  end
end
