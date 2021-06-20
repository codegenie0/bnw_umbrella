defmodule ComponentApplications.ExternalApplication do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_component_applications"
  prefix = case Application.get_env(:component_applications, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "external_applications" do
    field :name, :string
    field :url, :string

    timestamps()
  end

  def changeset(external_application, attrs \\ %{}) do
    external_application
    |> cast(attrs, [:name, :url])
    |> validate_required([:name, :url])
    |> unique_constraint(:name, name: :external_applications_name_index)
    |> check_url()
  end

  defp check_url(changeset) do
    {_, url} = fetch_field(changeset, :url)
    cond do
      String.starts_with?(url || "", ["http://", "https://"]) ->
        changeset
      true ->
        add_error(changeset, :url, "must begin with 'http://' or 'https://'")
    end
  end
end
