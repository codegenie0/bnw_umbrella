defmodule Reimbursement.Submissions do
  @moduledoc """
  Context for the entries page. This document give functions for applications to interface with the Reimbursement entries database.
  """

  import Ecto.Query
  alias Reimbursement.{
    Submission,
    Repo
  }

  @topic "reimbursement:entries"

  @doc """
  This function subscribes a user to changes in the reimbursement entries page.
  This allows for users to get a live update on their role within the application.
  """
  def subscribe(), do: Phoenix.PubSub.subscribe(Reimbursement.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(Reimbursement.PubSub, "#{@topic}:#{id}")
  @doc """
  This function unsubscribes a user to changes in the reimbursement entries page.
  """
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Reimbursement.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Reimbursement.PubSub, "#{@topic}:#{id}")

  @doc """
  Get all entries from the database.
  """
  def list_all_submission() do
    Repo.all(Submission)
  end

  # get the users submission for month year
  defp get_a_submission(user, month, year) do
    Submission
      |> where([submission],
                submission.user_id   == ^user
                and submission.month == ^month
                and submission.year  == ^year)
      |> Repo.one()
  end

  @doc """
  Check if a certain user has submitted for a specific month year
  """
  def get_submission(user, month, year) do
    sub = get_a_submission(user, month, year)

    # check if it exists
    cond do
      # if it does not exists return as though it is not submitted
      is_nil(sub) -> %{sub: 0, approved: 0, date: NaiveDateTime.utc_now()}
      true ->
        # if it does exists return weather or not it was submitted
        # if submitted include date
        %{submitted: sub, approved: approved, updated_at: date} = sub
        %{sub: sub, approved: approved, date: date}
    end
  end

  @doc """
  submit or unsubmit a month year
  """
  def set_submission(user, month, year, submission) do
    sub = get_a_submission(user, month, year)

    # check for approval.
    # a user can only change submission
    # if their reviewer has not approved
    approval = cond do
      sub ->
        %{approved: approval} = sub
        approval
      true ->
        0
    end
    # if previously submitted remove that submission
    if sub do
      Repo.delete(sub)
    end

    # add the new submission
    Repo.insert(%Submission{
                  user_id:   user,
                  month:     month,
                  year:      year,
                  submitted: submission,
                  approved:  approval
                })
    |> notify_subscribers([:submission, :created_or_updated])
  end

  @doc """
  set a submission as approved
  """
  def approve(user, month, year, approval) do
    sub = get_a_submission(user, month, year)

    # if submission exists drop
    if sub do
      Repo.delete(sub)
    end

    # create a new submission
    # submitted must be true
    # set approval
    Repo.insert(%Submission{
          user_id:   user,
          month:     month,
          year:      year,
          submitted: 1,
          approved:  approval
                })
    |> notify_subscribers([:submission, :created_or_updated])
  end

  @doc """
  create a new submission
  """
  def new_submission() do
    %Submission{}
  end

  @doc """
  get a changeset for a submission
  """
  def change_submission(%Submission{} = sub, attrs \\ %{}) do
    Submission.changeset(sub, attrs)
  end

  @doc """
  create or update a submission
  """
  def create_or_update_submission(%Submission{} = sub, attrs \\ %{}) do
    sub
    |> Submission.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:submission, :created_or_updated])
  end

  # Tell everyone who is subscribed about a change.
  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Reimbursement.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Reimbursement.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
