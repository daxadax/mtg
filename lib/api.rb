module Mtg
  class Api
    include AppHelpers
    attr_reader :errors

    def self.get_requested_sets(sets)
      new.get_requested_sets(sets)
    end

    def self.get_prices(sets)
      new.get_prices(sets)
    end

    def initialize
      @errors = Array.new
    end

    def get_requested_sets(sets)
      sets.flat_map do |set_id|
        pp "Fetching all cards in set #{set_id}"
        set_url = set_url(set_id)

        JSON.parse(fetch(set_url))
      end
    end

    def get_prices(sets)
      sets.inject(Hash.new) do |result, set_id|
        pp "Fetching prices for set #{set_id}"
        price_data = fetch(price_url(set_id))
        foil_data = fetch(price_url(set_id, foil: true))

        result[set_id] = MtgGoldfishPriceConverter.convert(set_id, price_data, foil_data)
        result
      end
    end

    private

    def fetch(uri_str, limit = 10)
      `curl -sL #{uri_str}`
    end

    def set_url(set_id)
      "https://mtgjson.com/api/v5/#{set_id}.json"
    end

    def price_url(set_id, foil: false)
      goldfish_set_id = goldfish_sets.fetch(set_id) { set_id }
      "https://www.mtggoldfish.com/index/#{goldfish_set_id}#{"_F" if foil}#paper"
    end

    def goldfish_sets
      {
        '7ED' => '7E',
        'APC' => 'AP',
        'EXO' => 'EX',
        'INV' => 'IN',
        'MIR' => 'MI',
        'MMQ' => 'MM',
        'NMS' => 'NE',
        'ODY' => 'OD',
        'PCY' => 'PR',
        'PLS' => 'PS',
        'STH' => 'ST',
        'TMP' => 'TE',
        'UDS' => 'UD',
        'ULG' => 'UL',
        'USG' => 'UZ',
        'VIS' => 'VI',
        'WTH' => 'WL'
      }
    end
  end
end
