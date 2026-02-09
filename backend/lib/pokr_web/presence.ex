defmodule PokrWeb.Presence do
  use Phoenix.Presence,
    otp_app: :pokr,
    pubsub_server: Pokr.PubSub
end
