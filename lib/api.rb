module Mtg
  class Api
    include AppHelpers
    attr_reader :errors

    def self.get_requested_sets(sets)
      new.get_requested_sets(sets)
    end

    def self.get_card_price(multiverse_id, foil)
      new.get_card_price(multiverse_id, foil)
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

    def get_card_price(multiverse_id, foil)
      begin
        data = JSON.parse(fetch(price_url(multiverse_id)))
        price_key = foil ? 'usd_foil' : 'usd'

        data['prices'][price_key]
      rescue JSON::ParserError
        p "RESCUING ERROR IN CARD WITH MULTIVERSE ID #{multiverse_id} #{foil ? 'foil' : nil}"
        return 0
      end
    end

    private

    def fetch(uri_str, limit = 10)
      `curl -sL #{uri_str}`
    end

    def set_url(set_id)
      "https://mtgjson.com/api/v5/#{set_id}.json"
    end

    def price_url(multiverse_id)
      "https://api.scryfall.com/cards/multiverse/#{multiverse_id}"
    end
  end
end
