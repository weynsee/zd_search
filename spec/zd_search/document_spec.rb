require "spec_helper"

RSpec.describe ZdSearch::Document do
  describe '#each_field' do
    it 'iterates through each of the fields in body' do
      body = { a: 1, b: 2 }
      doc = ZdSearch::Document.new(:thing, body)
      hash = {}
      doc.each_field do |k, v|
        hash[k] = v
      end
      expect(hash).to eq body
    end
  end
end
