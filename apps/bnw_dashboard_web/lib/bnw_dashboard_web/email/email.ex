defmodule BnwDashboardWeb.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: BnwDashboardWeb.EmailView

  def reset_password_email(user, temp_login_link) do
    base_email()
    |> to(user.email)
    |> subject("Password Reset")
    |> assign(:user, user)
    |> assign(:temp_login_link, temp_login_link)
    |> render(:reset_password)
  end

  def base_email do
    new_email()
    |> from("application_mailer@beefnw.com")
    |> put_html_layout({BnwDashboardWeb.LayoutView, "email.html"})
  end
end
