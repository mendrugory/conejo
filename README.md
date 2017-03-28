# Conejo

[![Build Status](https://travis-ci.org/mendrugory/conejo.svg?branch=master)](https://travis-ci.org/mendrugory/conejo) ![Hex.pm Downloads](https://img.shields.io/hexpm/dw/conejo.svg?maxAge=3600)

Conejo is an OTP application/library based on [pma/amqp](https://github.com/pma/amqp/) which will help you to define your
AMQP/RabbitMQ publishers and consumers in an easier way.

I highly recommend to initiate your publishers/consumers under a Supervisor.

## Installation
  * Add `conejo` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
       [{:conejo, "~> 0.2.0"}]
    end
    ```
    
## Configuration    
  * Define your config files. Try to respect this configuration. It is based
   on the options that are needed by [pma/amqp](https://github.com/pma/amqp/).
   
   ```elixir
   config :my_application, :consumer,
     exchange: "my_exchange",
     exchange_type: "topic",
     queue_name: "my_queue",
     queue_declaration_options: [{:auto_delete, true}, {:exclusive, true}],
     queue_bind_options: [routing_key: "example"],
     consume_options: [no_ack: true]


   config :conejo, 
     host: "my_host",
     port: 5672,
     username: "user",
     password: "pass"
   ```
   [Confex](https://github.com/Nebo15/confex) is supported.

## Consumer
  4. Define and run your Consumers. Code the function handle_consume(channel, tag, redelivered, payload)
   which will be executed when a message is received.
     
  ```elixir
  defmodule MyApplication.MyConsumer do
    use Conejo.Consumer

    def handle_consume(_channel, payload, _params) do
      IO.puts "Received  ->  #{inspect payload}"
    end
  end
     
  options = Application.get_all_env(:my_application)[:consumer] 
  {:ok, consumer} = MyApplication.MyConsumer.start_link(options, [name: :consumer])
  ```
  
## Publisher
  * Define and run your Publisher.
     
  ```elixir
  defmodule MyApplication.MyPublisher do
    use Conejo.Publisher
  
  end
     
  {:ok, publisher} = MyApplication.MyPublisher.start_link([], [name: :publisher])
  
  #Synchronous
  MyApplication.MyPublisher.sync_publish(:publisher, "my_exchange", "example", "Hola")
  
  #Asynchronous
  MyApplication.MyPublisher.async_publish(:publisher, "my_exchange", "example", "Adios")
  ```
  
## Test
  * Run the tests. You have to have [Docker](https://www.docker.com) installed in you computer.
  ```bash
  mix test --no-start
  ```
  
  