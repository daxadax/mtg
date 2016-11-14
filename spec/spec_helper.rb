require 'minitest'
require 'minitest/autorun'

$LOAD_PATH.unshift('lib', 'spec')

require 'mtg'

ENV['test'] = '1'

class Minitest::Spec
  include Mtg
end
