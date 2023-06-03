import Config

config :app,
  ecto_repos: [App.Repo]

config :app, App.Repo, database: "/data/db.db"

config :app, Oban,
  engine: Oban.Engines.Lite,
  repo: App.Repo,
  queues: [mailers: 10, scheduled: 1],
  plugins: [
    # Lets remove jobs in 2 weeks
    {Oban.Plugins.Pruner, max_age: 1_209_600},
    {Oban.Plugins.Cron,
     crontab: [
       {"@daily", App.GraduatesJob, queue: :scheduled, max_attempts: 5}
     ]}
  ]
