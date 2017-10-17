use Mix.Config

config :conejo,
 host: "0.0.0.0",
 port: 5672,
 username: "guest",
 password: "guest"

config :conejo, :consumer,
 exchange: "amq.topic",
 exchange_type: "topic",
 queue_name: "my_queue",
 queue_declaration_options: [{:auto_delete, true}, {:exclusive, true}],
 queue_bind_options: [routing_key: "example"],
 consume_options: [no_ack: true]

config :conejo, :publisher,
 exchange: "amq.topic",
 exchange_type: "topic"

