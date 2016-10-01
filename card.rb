module Mtg
  class Card
    ATTR = %i[
      name cmc cost is_foil multiverse_id quantity set set_id subtypes
      types market_price
    ]
    attr_reader(*ATTR)

    def initialize(attributes)
      @name = attributes['name']
      @cmc = attributes['cmc'].to_i
      @cost = attributes['cost']
      @is_foil = attributes['is_foil']
      @multiverse_id = attributes['multiverse_id']
      @quantity = attributes['quantity'].to_i
      @set = attributes['set']
      @set_id = attributes['set_id']
      @subtypes = attributes['subtypes']
      @types = attributes['types']
      # no price api access yet
      # overwrite me later!
      @market_price = 0
    end
  end
end
