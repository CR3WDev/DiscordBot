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
            String.starts_with?(msg.content,"!bank position ") -> handleRank(msg)
            String.starts_with?(msg.content,"!bank change ") -> handlechange24(msg)
            String.starts_with?(msg.content,"!bank record ") -> handleRecord(msg)
            msg.content == "!bank" -> handleHelp(msg)
        end
    end

    def handle_event(_event) do
        :noop
    end

    def handleHelp(msg) do 
        Api.create_message(msg.channel_id, "Comandos: \n 
        Use **!bank get <nome-da-crypto>** para pegar seu valor em brl \n
        Use **!bank image <nome-da-crypto>** para pegar sua imagem \n
        Use **!bank image <nome-da-crypto> <nome-da-crypto2>** para pegar a diferença da primeira pela segunda \n
        Use **!bank top** para pegar as 5 cryptos mais comercializadas \n
        Use **!bank position <nome-da-crypto>** para pegar o ranking da crypto \n
        Use **!bank change <nome-da-crypto>** para pegar a variação da crypto \n
        Use **!bank record <nome-da-crypto>** para pegar o maior valor que ela atingiu \n
         ")
    end

    defp handleRank(msg) do
        aux = String.split(msg.content, " ",parts: 3)
        crypto = Enum.fetch!(aux, 2)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/#{crypto}")

        {:ok, map} = Poison.decode(resp.body)

        rank = map["market_cap_rank"]

        if  map["market_cap_rank"] !== nil do
            Api.create_message(msg.channel_id, "O rank do #{crypto} é **#{rank}**")

        else
            Api.create_message(msg.channel_id, "Essa crypto não está listada no nosso ranqueamento")    

        end
            
    end

    defp handlechange24(msg) do
        aux = String.split(msg.content, " ",parts: 3)
        crypto = Enum.fetch!(aux, 2)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/#{crypto}")

        {:ok, map1} = Poison.decode(resp.body)
        {:ok, map2} = Poison.decode(resp.body)
        

        price = map1["market_data"]["price_change_24h_in_currency"]["brl"]
        prices = map2["market_data"]["price_change_percentage_24h"]

        if  map1["market_data"]["price_change_24h_in_currency"]["brl"] !== nil do
            Api.create_message(msg.channel_id, "A Moeda teve uma variação em 24hrs de **#{prices}%** ou seja **#{price}** reais")

        else
            Api.create_message(msg.channel_id, "Não conseguimos achar essa crypto, por favor verifique a nomeclatura ")    

        end
            
    end

    defp handleRecord(msg) do
        aux = String.split(msg.content, " ",parts: 3)
        crypto = Enum.fetch!(aux, 2)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/#{crypto}")

        {:ok, map} = Poison.decode(resp.body)

         record = map["market_data"]["ath"]["brl"]

        if  map["market_data"]["ath"]["brl"] !== nil do
            Api.create_message(msg.channel_id, "A alta record de #{crypto} é **#{record}** reais")

        else
            Api.create_message(msg.channel_id, "Essa crypto não está listada")    

        end
    end

    defp handleCurrentValue(msg) do
        aux = String.split(msg.content, " ", parts: 3)
        crypto = Enum.fetch!(aux, 2)

        resp = HTTPoison.get!("https://api.coingecko.com/api/v3/coins/#{crypto}")

        {:ok, map} = Poison.decode(resp.body)

       if map["symbol"] !== nil do
        amount = map["market_data"]["current_price"]["brl"]
        Api.create_message(msg.channel_id, "o valor do #{crypto} agora é R$ #{amount} ")
                
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
            Api.create_message(msg.channel_id, "#{crypto1} menos #{crypto2} é = R$ #{amount1 - amount2}")
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

end