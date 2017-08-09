require "spec_helper"

RSpec.describe ZdSearch::JSONSearchStore do
  it 'loads the files in the given directory' do
    store = ZdSearch::JSONSearchStore.new('spec/fixtures')
    expect(store.size).to eq 6
  end

  it 'searches with the given attributes' do
    store = ZdSearch::JSONSearchStore.new('spec/fixtures')
    results = store.search(name: 'Cross Barlow')
    expect(results.size).to eq 1
    expect(results.first.body['_id']).to eq 2
  end
end
