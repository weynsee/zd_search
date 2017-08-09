require "spec_helper"

RSpec.describe ZdSearch::FlagParser do
  it 'defaults data_dir to data' do
    config = ZdSearch::FlagParser.parse([])
    expect(config.data_dir).to eq 'data'
  end

  it 'sets the data_dir' do
    config = ZdSearch::FlagParser.parse(['-d', 'blah'])
    expect(config.data_dir).to eq 'blah'
  end

  it 'sets the query' do
    config = ZdSearch::FlagParser.parse(['blah'])
    expect(config.query).to eq 'blah'
  end

  it 'sets the filter' do
    config = ZdSearch::FlagParser.parse(['--', 'name=Bruce', 'age=7'])
    expect(config.filters).to include('name' => 'Bruce', 'age' => '7')
  end

  it 'sets all the options' do
    config = ZdSearch::FlagParser.parse(['--data-dir', 'path', 'test', '--', 'status=', 'name=Bruce', 'age=7'])
    expect(config.filters).to include('name' => 'Bruce', 'age' => '7', 'status' => nil)
    expect(config.query).to eq 'test'
    expect(config.data_dir).to eq 'path'
  end
end
