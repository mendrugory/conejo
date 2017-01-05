use Mix.Config

config :conejo,
 host: "127.0.0.1",
 port: 5672,
 username: "guest",
 password: "guest"

config :conejo, :publisher,
 exchange: "amq.topic",
 exchange_type: "topic",
 routing_key3: "example3"

config :conejo, :consumer3,
 exchange: "amq.topic",
 exchange_type: "topic",
 queue_name: "my_queue_3",
 queue_declaration_options: [{:auto_delete, true}, {:exclusive, true}],
 queue_bind_options: [routing_key: "example3"],
 consume_options: [no_ack: true]


