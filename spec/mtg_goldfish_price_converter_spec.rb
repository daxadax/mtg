require 'spec_helper'

class MtgGoldfishPriceConverterSpec < Minitest::Spec
  let(:fixture_path) { '../fixtures/mtg_goldfish.html' }
  let(:foil_fixture_path) { '../fixtures/mtg_goldfish_foil.html' }
  let(:data) { File.read(File.expand_path(fixture_path, __FILE__)) }
  let(:foil_data) { File.read(File.expand_path(foil_fixture_path, __FILE__)) }
  let(:result) { MtgGoldfishPriceConverter.convert('SET', data, foil_data) }

  it 'returns prices as hash keyed by name' do
    assert_equal(1.3, result['Rainbow Vale'])
    assert_equal(12.3, result[:foil]['Rainbow Vale'])
  end

  it 'escapes html apostrophes' do
    assert_equal(result["Delif's Cone"], 0.17)
  end

  describe 'when no foil cards exist for a set' do
    let(:foil_fixture_path) { '../fixtures/mtg_goldfish_no_foil.html' }

    it 'returns the regular price but no foil price' do
      assert_equal(1.3, result['Rainbow Vale'])
      assert_nil(result[:foil]['Rainbow Vale'])
    end
  end
end
