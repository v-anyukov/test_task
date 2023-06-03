defmodule App.ApiClient do
  @moduledoc """
  Randomuser api client
  """
  @base_url "https://randomuser.me/api/?seed=jobmensa"
  @per_page 10

  require Logger

  @doc """
  This function returns a stream of random users.
  Given the potential for the stream to be infinite,
  it is the responsibility of the user to handle and utilize the stream in a prudent manner.
  """
  def stream() do
    start_fn = fn -> {1} end

    next_fn = fn
      {page} ->
        # TODO Handle errors properly
        {:ok, results} = fetch(page)
        {results, {page + 1}}
    end

    after_fn = fn _ -> nil end

    Stream.resource(start_fn, next_fn, after_fn)
  end

  defp fetch(page) do
    with {:ok, resp} <- do_request(page),
         %{status: 200, body: %{"results" => results}} <- resp do
      {:ok, results}
    else
      _ -> {:error, "Error fetching"}
    end
  end

  defp do_request(page) do
    Logger.info("Request page #{page}")

    Req.new(base_url: @base_url)
    |> Req.get(params: [results: @per_page, page: page])
  end
end
