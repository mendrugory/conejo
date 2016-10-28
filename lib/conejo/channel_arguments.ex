defmodule Conejo.ChannelArguments do
  @moduledoc """
  Arguments for the Conejo.Channel.
  """
  defstruct   consumer?: true,
              queue_arguments: %{name: "", args: []},
              no_ack: true,
              exchange: "",
              exchange_type: "topic"
end