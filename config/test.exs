use Mix.Config

config :lager,
  handlers: [level: :info]

config :conejo,
  host: "127.0.0.1",
  port: 5672,
  username: "guest",
  password: "guest"

config :conejo, :publisher3,
  exchange: "amq.topic",
  exchange_type: "topic",
  routing_key: "example3"

config :conejo, :consumer3,
  exchange: "amq.topic",
  exchange_type: "topic",
  queue_name: "my_queue_3",
  queue_declaration_options: [{:auto_delete, true}, {:exclusive, true}],
  queue_bind_options: [routing_key: "example3"],
  consume_options: [no_ack: true]

config :conejo, :publisher4,
  exchange: "amq.topic",
  exchange_type: "topic",
  routing_key: "example4"

config :conejo, :consumer4,
  exchange: "amq.topic",
  exchange_type: "topic",
  queue_name: "my_queue_4",
  queue_declaration_options: [{:auto_delete, true}, {:exclusive, true}],
  queue_bind_options: [routing_key: "example4"],
  consume_options: [no_ack: false]

config :conejo, :publisher5,
  exchange: "amq.topic",
  exchange_type: "topic",
  routing_key: "example5"

config :conejo, :consumer5,
  exchange: "amq.topic",
  exchange_type: "topic",
  queue_name: "my_queue_5",
  queue_declaration_options: [{:auto_delete, true}, {:exclusive, true}],
  queue_bind_options: [routing_key: "example5"],
  consume_options: [no_ack: false]

  config :conejo, :publisher6,
  exchange: "amq.topic",
  exchange_type: "topic",
  routing_key: "example6"

config :conejo, :consumer6,
  exchange: "amq.topic",
  exchange_type: "topic",
  queue_name: "my_queue_6",
  queue_declaration_options: [{:auto_delete, true}, {:exclusive, true}],
  queue_bind_options: [routing_key: "example6"],
  consume_options: [no_ack: false]  
