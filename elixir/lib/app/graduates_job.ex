defmodule App.GraduatesJob do
  @moduledoc false
  use Oban.Worker

  alias App.ApiClient
  alias App.Mailer

  require Logger

  @daily_limit 100

  @impl Oban.Worker
  @doc """
  This function schedules emails to be sent to graduates.
  It starts by pausing the mailer queue, and then retrieves the current unfinished jobs.
  Next, it calculates how many additional jobs can be added without exceeding the daily limit.
  After this, jobs from the ApiClient stream are added to the queue.
  The process halts immediately if a duplicate email is detected (since the API's order is assumed to be constant)
  or when the daily limit is reached. The mailer queue is resumed afterwards.
  """
  def perform(%Oban.Job{} = _job) do
    Logger.info("Performing graduates scheduler")

    Oban.pause_queue(queue: :mailers)

    currently_scheduled_jobs = Mailer.get_unfinished_jobs_count!()

    limit = @daily_limit - currently_scheduled_jobs

    Logger.info("Found #{currently_scheduled_jobs} unfinished jobs - setting limit to #{limit}")

    _res =
      ApiClient.stream()
      |> Enum.reduce_while(limit, &reducer/2)

    Oban.resume_queue(queue: :mailers)

    :ok
  end

  defp reducer(%{"email" => email, "dob" => %{"age" => age}}, acc) do
    case acc > 0 do
      true ->
        case schedule_email(age, email) do
          {:ok, %Oban.Job{conflict?: true}} ->
            Logger.info("Duplicated email #{email}: stopping scheduler")
            {:halt, acc}

          {:ok, _res} ->
            {:cont, acc - 1}

          # TODO decide what do we do here!
          {:error, _changeset} ->
            {:halt, acc}
        end

      _ ->
        {:halt, acc}
    end
  end

  defp schedule_email(age, email) do
    %{email: email, text: Mailer.get_email_text(age)}
    |> App.MailerJob.new()
    |> Mailer.insert()
  end
end
