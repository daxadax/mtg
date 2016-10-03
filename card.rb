module Mtg
  class Card
    ATTR = %i[
      name cmc colors cost is_foil multiverse_id
      quantity rarity set set_id subtypes
      types market_price
    ]
    attr_reader(*ATTR)

    def initialize(attributes)
      @name = attributes['name']
      @cmc = attributes['cmc'].to_i
      @colors = attributes['colors']
      @cost = attributes['cost']
      @is_foil = attributes['is_foil']
      @market_price = attributes['market_price']
      @multiverse_id = attributes['multiverse_id']
      @quantity = attributes['quantity'].to_i
      @rarity = attributes['rarity']
      @set = attributes['set']
      @set_id = attributes['set_id']
      @subtypes = attributes['subtypes']
      @types = attributes['types']
    end
  end
end
