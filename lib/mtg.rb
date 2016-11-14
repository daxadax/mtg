require_relative 'app_helpers.rb'
require_relative 'api.rb'
require_relative 'app.rb'
require_relative 'card.rb'
require_relative 'informant.rb'
require_relative 'mtg_goldfish_price_converter.rb'

module Mtg
end

Mtg::App.run
