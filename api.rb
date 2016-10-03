module Mtg
  class Api
    attr_reader :set_id, :name, :quantity, :is_foil, :overwrite_id,
      :errors

    def self.get_card(card)
      new(card).get_card
    end

    def initialize(card)
      @set_id = card['set_id']
      @name = card['name']
      @quantity = card['quantity']
      @is_foil = card['is_foil']
      @overwrite_id = card['multiverse_id']
      @errors = Array.new
    end

    def get_card
      print "Fetching information for #{name}\n"
      response = JSON.parse(fetch_card)

      if errors.any?
        print "--- '#{name}' not found ---"
        { errors: errors }
      else
        set_attributes = get_set_attributes(response)
        set = set_attributes.fetch('set') { no_set_found }

        {
          name: name,
          cmc: response['cmc'],
          colors: response['colors'],
          cost: response['cost'],
          is_foil: is_foil,
          market_price: market_price(name, set, is_foil),
          multiverse_id: overwrite_id || set_attributes['multiverse_id'],
          quantity: quantity,
          rarity: set_attributes.fetch('rarity') { no_set_found },
          set: set,
          set_id: set_id,
          subtypes: response['subtypes'],
          types: response['types'],
          errors: errors
        }
      end
    end

    private

    def fetch_card
      fetch(card_url)
    end

    def fetch(uri_str, limit = 10)
      url = URI.parse(URI.encode(uri_str))
      req = Net::HTTP::Get.new(url.path)
      response = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end

      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        fetch(response['location'], limit - 1)
      else
        errors.push "\n\nCan't find card #{name}\n\n"
        '{}'
      end
    end

    def no_set_found
      errors.push("Can't find set for #{name} in #{set_id}")
    end

    def get_set_attributes(response)
      response['editions'].detect do |edition|
        edition['set_id'] == set_id
      end || {}
    end

    def market_price(name, set, is_foil)
      url = build_price_url(name, set, is_foil)
      # remove new lines and extra spaces
      res = fetch(url).split.join(' ')
      data = /card-name.*<\/h2>/.match(res)

      return 0 if data.nil?
      data[0].match(/\d*\.\d*/)[0].to_f
    end

    def build_price_url(name, set, is_foil)
      set = underscore(set)
      set += "_Foil" if is_foil == 'true'

      "http://www.mtgprice.com/sets/#{set}/#{underscore(name)}"
    end

    def underscore(string)
      string.split.join('_')
    end

    def card_url
      base_api_url + "/#{card_id}"
    end

    def base_api_url
      "http://api.deckbrew.com/mtg/cards"
    end

    def card_id
      subs = {
        '\''  => '',
        ','   => '',
        ' '   => '-',
        'Æ'   => 'æ'
      }
      name.gsub(/./) { |char| subs.fetch(char, char) }.downcase
    end
  end
end
