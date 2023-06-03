defmodule App.MailerJob do
  @moduledoc false
  use Oban.Worker,
    queue: :mailers,
    unique: [fields: [:args, :queue, :worker], keys: [:email], period: :infinity]

  require Logger

  @impl Oban.Worker
  @doc """
  We mock email sending here
  """
  def perform(%Oban.Job{args: %{"email" => email, "text" => text} = args}) do
    Process.sleep(500)

    # Trick to emulate mailer api errors
    case Enum.random([:ok, :ok, :ok, :error]) do
      :ok ->
        Logger.info("Sent email to #{email} with text: #{text}")
        {:ok, args}

      :error ->
        Logger.error("Error sending email to #{email} with text: #{text}")
        {:error, args}
    end
  end
end
