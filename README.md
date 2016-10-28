# Conejo

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `conejo` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:conejo, "~> 0.1.0"}]
    end
    ```

  2. Ensure `conejo` is started before your application:

    ```elixir
    def application do
      [applications: [:conejo]]
    end
    ```

  
  ```elixir
    defmodule MyChannel do
      use Conejo.Channel
  
      def consume(channel, tag, redelivered, payload) do
        IO.puts("Receiving: #{inspect payload}")
      end
  
      def handle_data_and_publish(channel, data) do
        IO.puts("Publishing: #{inspect data}")
      end
      
    end
    
  ```
