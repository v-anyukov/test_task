FROM elixir:1.14.5-otp-25-slim

WORKDIR /app

RUN apt-get update -y && apt-get install -y build-essential inotify-tools sqlite3 && apt-get clean