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

    def self.info
      new(requested_sets).info
    end

    def self.merge_duplicates
      new(requested_sets).merge_duplicates
    end

    def self.method_missing(method_name)
      pp "No command named '#{method_name}'", :new_line
      return
    end

    def initialize(requested_sets)
      @requested_sets = requested_sets
      @errors = []
    end

    def update
      updated_cards = write_updates
      report_status(updated_cards)
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

      pp "#{result[:count]} cards worth $#{result[:price]}", :new_line
    end

    private
    attr_reader :errors, :requested_sets

    def write_updates
      cards = fetch_raw_collection
      grouped = cards.group_by{ |c| JSON.parse(c)['set_id'] }

      grouped.each do |set, members|
        File.write(path_to_file("collection/#{set}.json"), members)
      end

      cards
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
      cards = manifest.inject([]) do |array, card|
        attributes = Mtg::Api.get_card(card)
        errors.push(attributes.delete(:errors))

        array << attributes.to_json
      end

      # cards with errors return an empty hash, so remove them
      cards.reject(&:empty?)
    end


    def manifest
      data = CSV.read(source_file, headers: true)
      return data if requested_sets.empty?
      data.select { |c| requested_sets.include?(c['set_id']) }
    end

    def collection
      JSON.parse(File.read(target_file)).map do |card|
        Mtg::Card.new(JSON.parse(card))
      end
    end

    def target_file
      path_to_file('collection.json')
    end

    def source_file
      path_to_file('manifest.csv')
    end

    def path_to_file(name)
      File.join(File.dirname(__FILE__), name)
    end
  end
end
