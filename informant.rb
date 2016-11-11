module Mtg
  class Informant
    require 'net/http'
    require 'json'
    require 'csv'
    require './api.rb'
    require './card.rb'
    require './informant.rb'
    require './app_helpers.rb'
    include Mtg::AppHelpers

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


    def initialize(requested_sets = Array.new)
      @requested_sets = requested_sets
      @errors = []
    end

    def update
      collection = fetch_raw_collection
      cards_by_set = collection.group_by { |c| JSON.parse(c)['set_id'] }

      cards_by_set.each { |set, cards| update_set(set, cards) }
      report_status(collection)
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
      pp "#{rarities.count('common')} commons"
      pp "#{rarities.count('uncommon')} uncommons"
      pp "#{rarities.count('rare')} rares"
      pp "#{rarities.count('mythic')} mythic rares", :new_line
    end

    def top_cards
      collection.sort_by(&:market_price).reverse.first(25).each do |card|
        pp "#{card.quantity}x #{card.name}(#{card.set_id}): #{card.market_price}"
      end
    end

    private
    attr_reader :errors, :requested_sets

    def update_set(set, cards)
      File.write(path_to_file("collection/#{set}.json"), cards)
    end

    def report_status(updated_cards)
      e = errors.flatten

      if e.any?
        pp "Finished with #{e.count} errors", :new_line
        pp "~~ Errors ~~", :new_line
        e.uniq.each { |error| pp error }
      else
        msg = "Updated #{updated_cards.count} cards with no errors"
        pp msg, :clear_screen
      end
    end

    def fetch_raw_collection
      prices = fetch_prices
      p prices: prices
      cards = manifest.inject([]) do |array, card|
        attributes = Mtg::Api.get_card(card)
        errors.push(attributes.delete(:errors))

        array << attributes.to_json
      end

      # cards with errors return an empty hash, so remove them
      cards.reject(&:empty?)
    end

    def fetch_prices
      # for now, only fetch prices for individual sets
      return Hash.new if requested_sets.empty?
      Mtg::Api.get_prices(requested_sets)
    end

    def manifest
      data = CSV.read(source_file, headers: true)
      return data if requested_sets.empty?
      data.select { |c| requested_sets.include?(c['set_id']) }
    end

    def collection
      sets = requested_sets.empty? ? all_sets : requested_sets

      sets.flat_map do |set|
        file = File.read(path_to_file("collection/#{set}.json"))
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
      path_to_file('manifest.csv')
    end

    def path_to_file(name)
      File.join(File.dirname(__FILE__), name)
    end
  end
end
