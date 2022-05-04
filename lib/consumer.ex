defmodule Bot.Consumer do

    use Nostrum.Consumer
    alias Nostrum.Api

    def start_link do 
        Consumer.start_link(__MODULE__)
    end

    def handle_event({:MESSAGE_CREATE,msg,_ws_state}) do
        cond do
            String.starts_with?(msg.content,"!bank get") -> handleCurrentValue(msg)
            String.starts_with?(msg.content,"!bank image") -> handleGetImage(msg)
            String.starts_with?(msg.content,"!bank difference") -> handleGetBest(msg)
            String.starts_with?(msg.content,"!bank top") -> handleGetTop(msg)
            String.starts_with?(msg.content,"!bank amount ") -> handleGetAmount(msg)
            String.starts_with?(msg.content,"!age ") -> handleAge(msg)
            String.starts_with?(msg.content,"!email ") -> handleVerifyEmail(msg)
            msg.content == "!bank" -> handleHelp(msg)
            msg.content == "!duck" -> handleDuck(msg)
            msg.content == "!cn" -> handleChuckNorris(msg)
        end
    end

    def handle_event(_event) do
        :noop
    end

    def handleHelp(msg) do 
        Api.create_message(msg.channel_id, "Comandos: \n 
        Use **!bank get <nome-da-crypto>** para pegar seu valor em brl \n
        Use **!bank image <nome-da-crypto>** para pegar sua imagem \n
        Use **!bank difference <nome-da-crypto> <nome-da-crypto2>** para pegar a diferença da primeira pela segunda \n
        Use **!bank top** para pegar as 5 cryptos mais comercializadas \n
         ")
    end

    defp handleCurrentValue(msg) do
        aux = String.split(msg.content, " ", parts: 3)
        crypto = Enum.fetch!(aux, 2)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/#{crypto}")

        {:ok, map} = Poison.decode(resp.body)

       if map["symbol"] !== nil do
        amount = map["market_data"]["current_price"]["brl"]
        Api.create_message(msg.channel_id, "o valor do #{crypto} agora é R$ **#{amount}** ")
                
       else
        Api.create_message(msg.channel_id, "#{crypto} não foi encontrado. Tente novamente!")
       end
    end
    
    defp handleGetImage(msg) do
        aux = String.split(msg.content, " ", parts: 3)
        crypto = Enum.fetch!(aux, 2)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/#{crypto}")

        {:ok, map} = Poison.decode(resp.body)
        image = map["image"]["small"];
        if image do
            Api.create_message(msg.channel_id, image )
        else
            Api.create_message(msg.channel_id, "#{crypto} não foi encontrado. Tente novamente!")
        end
    end

    defp handleGetBest(msg) do
        aux = String.split(msg.content, " ", parts: 4)
        crypto1 = Enum.fetch!(aux, 2)
        crypto2 = Enum.fetch!(aux, 3)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/#{crypto1}")
        {:ok, map1} = Poison.decode(resp.body)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/#{crypto2}")
        {:ok, map2} = Poison.decode(resp.body)

        if map1["symbol"] !== nil && map2["symbol"] do
            amount1 = map1["market_data"]["current_price"]["brl"]
            amount2 = map2["market_data"]["current_price"]["brl"]
            Api.create_message(msg.channel_id, "#{crypto1} menos #{crypto2} é = R$ **#{amount1 - amount2}**")
        else
            Api.create_message(msg.channel_id, "por favor, digite 2 cryptomoedas válidas")
        end
    end

    defp handleGetTop(msg) do
        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=5&page=1&sparkline=false")
        {:ok, map} = Poison.decode(resp.body)

        Api.create_message(msg.channel_id, "Ranking das Cryptosmoedas \n
        1 - #{Enum.fetch!(map,0)["name"]} \n
        2 - #{Enum.fetch!(map,1)["name"]} \n
        3 - #{Enum.fetch!(map,2)["name"]} \n
        4 - #{Enum.fetch!(map,3)["name"]} \n
        5 - #{Enum.fetch!(map,4)["name"]} \n")
    end

    def handleGetAmount(msg) do
        aux = String.split(msg.content, " ", parts: 4)
        quantity = String.to_integer(Enum.fetch!(aux, 2))
        crypto = Enum.fetch!(aux, 3)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/bitcoin")
        {:ok, map} = Poison.decode(resp.body)
        symbol = map["symbol"]
        if symbol !== nil do
             currentValue = map["market_data"]["current_price"]["brl"]
            Api.create_message(msg.channel_id, "R$ **#{quantity} em #{crypto}** da **#{Float.round(quantity/currentValue, 5)}** #{String.upcase(symbol)}")
        else
            Api.create_message(msg.channel_id, "por favor, digite 2 cryptomoedas válidas")
        end
    end

    def handleDuck(msg) do
        resp = HTTPoison.get!("https://random-d.uk/api/v2/random")
        {:ok, map} = Poison.decode(resp.body)
        duckImage = map["url"]

        Api.create_message(msg.channel_id, duckImage)
    end

    def handleChuckNorris(msg) do
        resp = HTTPoison.get!("http://api.icndb.com/jokes/random")
        {:ok, map} = Poison.decode(resp.body)
        joke = map["value"]["joke"]

        Api.create_message(msg.channel_id, joke)
    end
    
    def handleAge(msg) do
        aux = String.split(msg.content, " ", parts: 2)
        firstName = Enum.fetch!(aux, 1)
        resp = HTTPoison.get!("https://api.agify.io/?name=#{firstName}")
        {:ok, map} = Poison.decode(resp.body)
        age = map["age"]
        name = map["name"]
        cond do
            age < 20 ->
                Api.create_message(msg.channel_id, "pro nosso sistema **#{name}** ainda é um bebezinho de #{age} vá estudar")
            age >= 20 && age < 30 ->
                Api.create_message(msg.channel_id, "**#{name}**, você é um(a) novinho(a) de #{age}")
            age >= 30 && age < 40 ->
                Api.create_message(msg.channel_id, "**#{name}**, você tem #{age}, já ta numa idade de casar eim ")
            age >= 40 && age < 60 ->
                Api.create_message(msg.channel_id, "**#{name}**, você já viveu bastante e tem #{age}, tá na hora de se endividar!! ")
            age >= 60  ->
                Api.create_message(msg.channel_id, "**#{name}** é nome de quem sobreviveu por vários #{age} anos e vai viver pra sempre!!  ")
        end
    end
    def handleVerifyEmail(msg) do 
        aux = String.split(msg.content, " ", parts: 2)
        email = Enum.fetch!(aux, 1)
        resp = HTTPoison.get!("https://www.disify.com/api/email/#{email}")
        {:ok, map} = Poison.decode(resp.body)
        isValidEmail = map["format"]
        if isValidEmail do
            Api.create_message(msg.channel_id, "**#{email}** é um email válido")
        else
            Api.create_message(msg.channel_id, "**#{email}** não é um email válido")
        end
    end

end