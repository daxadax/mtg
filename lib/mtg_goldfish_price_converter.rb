module Mtg
  class MtgGoldfishPriceConverter
    include AppHelpers

    def self.convert(set, data, foil_data)
      new(set, data, foil_data).convert
    end

    def initialize(set, data, foil_data)
      @set = set
      @data = separate_cards(data)
      @foil_data = separate_cards(foil_data)
      @prices = { foil: {} }
    end

    def convert
      add_prices(data)
      add_prices(foil_data, foil: true)

      prices
    end

    private
    attr_reader :set, :data, :foil_data, :prices

    def add_prices(html, foil: false)
      html.split("<td class='card'>").each do |card_body|
        name = name(card_body)
        price = price(card_body)
        next if name.nil? || price.nil?

        if foil
          prices[:foil][name] = price
        else
          prices[name] = price
        end
      end
    end

    def name(card)
      raw_name = card.match(/>.*?(?=<\/a)/)
      raw_name[0].sub('>', '').sub('&#39;', "'") if raw_name
    end

    def price(card)
      raw_price = card.match(/right'>\n\d+.\d+/)
      raw_price[0].sub("right'>\n",'').to_f if raw_price
    end

    def separate_cards(response)
      if data_exists?(response)
        regex = /index-price-table-paper.*<div class='index-price/m
        response.match(regex)[0]
      else
        pp "No prices found for set #{set}"
        ""
      end
    end

    def data_exists?(response)
      !response.include?("Oops! Page not found!")
    end
  end
end
