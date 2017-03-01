module Mtg
  class Informant
    include AppHelpers
    require 'net/http'
    require 'json'
    require 'csv'

    def self.update(requested_sets)
      new(requested_sets).update
    end

    def self.info(requested_sets)
      new(requested_sets).info
    end

    def self.merge_duplicates(requested_sets)
      new(requested_sets).merge_duplicates
    end

    def self.top_cards(requested_sets)
      new(requested_sets).top_cards
    end

    def self.method_missing(method_name)
      pp "No command named '#{method_name}'", :new_line
      return
    end


    def initialize(requested_sets)
      @requested_sets = requested_sets.empty? ? all_sets : requested_sets
      @errors = []
    end

    def update
      updated_cards_count = fetch_raw_collection
      report_status(updated_cards_count)
    end

    def update_prices
      pp 'NOT IMPLEMENTED', :new_line
    end

    def merge_duplicates
      pp 'NOT IMPLEMENTED', :new_line
    end

    def info
      result = collection.inject(Hash.new(0)) do |sum, card|
        sum[:count] += card.quantity
        sum[:price] += card.market_price
        sum
      end

      rarities = collection.map(&:rarity)

      pp "#{result[:count]} cards worth $#{result[:price]}", :new_line
      pp "#{rarities.count('Common')} commons"
      pp "#{rarities.count('Uncommon')} uncommons"
      pp "#{rarities.count('Rare')} rares"
      pp "#{rarities.count('Mythic Rare')} mythic rares", :new_line
    end

    def top_cards
      collection.sort_by(&:market_price).reverse.first(50).each do |card|
        pp "#{card.quantity}x #{card.name}(#{card.set_id}): #{card.market_price}"
      end
      pp '', :new_line
    end

    private
    attr_reader :errors, :requested_sets

    def update_set(set_id, cards)
      File.write(path_to_file("../../collection/#{set_id}.json"), cards)
    end

    def report_status(updated_cards_count)
      e = errors.flatten
      msg = "Updated #{updated_cards_count} cards with #{e.count} errors"

      pp '', :new_line
      pp "~~ Results ~~"
      pp msg, :new_line

      if e.any?
        pp "~~ Errors ~~"
        e.uniq.each { |error| pp error }
        pp '', :new_line
      end
    end

    # make one call for prices (per set)
    # make one call for cards (per set)
    def fetch_raw_collection
      sets = Mtg::Api.get_requested_sets(requested_sets.sort)
      prices = Mtg::Api.get_prices(requested_sets.sort)
      updated_cards_count = 0

      sets.each do |set|
        cards = manifest.select { |c| c['set_id'] == set['code'] }
        pp "Updating #{cards.count} cards in set #{set['name']} (#{set['code']})"
        updated_cards_count += cards.count

        updated_cards = cards.map do |card|
          response = set['cards'].detect { |c| c['name'] == sanitize(card['name']) }

          if response.nil?
            errors.push("Couldn't find card '#{card['name']}' in set '#{set['code']}'")
            next
          else
            {
              name: card['name'],
              cmc: response['cmc'],
              colors: response['colors'],
              cost: response['manaCost'],
              is_foil: card['is_foil'],
              market_price: price_for(prices, card, set),
              multiverse_id: card['multiverse_id'] || response['multiverseid'],
              quantity: card['quantity'],
              rarity: response['rarity'],
              set: set['name'],
              set_id: set['code'],
              subtypes: response['subtypes'] || Array.new,
              types: response['types'],
            }.to_json
          end
        end

        update_set(set['code'], updated_cards)
      end

      updated_cards_count
    end

    def price_for(prices, card, set)
      set_prices = prices[set['code']]

      if card['is_foil'] == 'true'
        set_prices[:foil][card['name']]
      else
        set_prices[card['name']]
      end
    end

    def sanitize(name)
      subs = {
        'Æ'   => 'Ae'
      }
      name.gsub(/./) { |char| subs.fetch(char, char) }
    end

    def manifest
      data = CSV.read(source_file, headers: true)
      return data if requested_sets.empty?
      data.select { |c| requested_sets.include?(c['set_id']) }
    end

    def collection
      requested_sets.flat_map do |set|
        file = File.read(path_to_file("../../collection/#{set}.json"))
        JSON.parse(file).map do |card|
          Mtg::Card.new(JSON.parse(card))
        end
      end
    end

    def all_sets
      Dir['collection/*.json'].map do |f|
        f.sub!('collection/', '')
        f.sub!('.json', '')
      end
    end

    def source_file
      path_to_file('../../manifest.csv')
    end

    def path_to_file(name)
      File.expand_path(name, __FILE__)
    end
  end
end
