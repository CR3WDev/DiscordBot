defmodule Bot.Consumer do

    use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do 
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE,msg,_ws_state}) do
        case msg.content do
            "!ping" -> Api.create_message(msg.channel_id,"pong")
            "!poesia" -> Api.create_message(msg.channel_id,"Á mão da punheta é a mesma da poesia. ambas me levam o gozo. uma traz alivio a alma a outra o corpo. todo poeta é um punheteiro nato. quando não a masturba sentimentos, ideias, egos de outros. a porra de um poeta jorra em forma de palavras. tem gente que engole e outras que cospem.")
             _-> :ignore
        end
    end

    def handle_event(_event) do
        :noop
    end

end