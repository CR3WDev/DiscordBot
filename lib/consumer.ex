defmodule Bot.Consumer do

    use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do 
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE,msg,_ws_state}) do
        cond do
            String.starts_with?(msg.content,"!tempo") -> handleWeather(msg)
            msg.content == "!tempo" -> Api.create_message(msg.channel_id, "Use **!tempo <nome-da-cidade>** ")
        end
    end
    defp handleWeather(msg) do
        aux = String.split(msg.content, "",parts: 2)
        cidade = Enum.fetch!(aux, 1)

        resp = HTTPoison.get!("https://api.openweathermap.org/data/2.5/weather?q=#{cidade}&appid=5708f8391084ab65db5f444ca3cfd3a1&units=metric&lang=pt_br")

        {:ok, map} = Poison.decode(resp.body)

        case map["cod"] do 
            200 ->
                temp = map["main"]["temp"]
                Api.create_message(msg.channel_id, "a temporatura da cidade #{cidade} é de #{temp}")
            
            "404" ->
                Api.create_message(msg.channel_id, "A cidade #{cidade} não foi encontrada!. Tente novamente!")
        end
        
    end

    def handle_event(_event) do
        :noop
    end

end