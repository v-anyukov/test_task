defmodule App.Mailer do
  @moduledoc """
  Mailer context
  """
  import Ecto.Query

  alias App.Repo

  @doc """
  Returns number of unfinished Oban jobs. :discarded, :cancelled, :completed are considered as finished.
  """
  def get_unfinished_jobs_count!() do
    states =
      (Oban.Job.states() -- [:discarded, :cancelled, :completed]) |> Enum.map(&Atom.to_string/1)

    from(j in Oban.Job,
      where: j.state in ^states,
      select: count(j.id)
    )
    |> Repo.one!()
  end

  @doc """
  Returns email text depending on age. If age > 25 returns "Next step in your career", else - "Get your first job!"
  """
  def get_email_text(age) when age > 25 do
    "Next step in your career"
  end

  def get_email_text(_age) do
    "Get your first job!"
  end

  defdelegate insert(job), to: Oban
end
