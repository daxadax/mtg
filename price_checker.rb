module Mtg
  class PriceChecker
    def initalize(

    market_price: market_price(name, set, is_foil),
    def market_price(name, set, is_foil)
      url = build_price_url(name, set, is_foil)
      # remove new lines and extra spaces
      res = fetch(url).match(/<title>(.*?)<\/title>/)

      if res.nil?
        errors.push("No price data found for #{name} in #{set_id}")
        return 0
      else
        price = res[0].match(/\d*\.\d*/)

        if price.nil?
          errors.push("No price data found for #{name} in #{set_id}")
          return 0
        else
          price[0].to_f
        end
      end

    end


    def underscore(string)
      string.split.join('_')
    end
  end
end
