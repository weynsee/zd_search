require "spec_helper"

RSpec.describe ZdSearch::CLI do
  let(:args) { ['-d', 'spec/fixtures'] }

  describe '.start' do
    it 'prints no filters specified when none are passed' do
      out = StringIO.new
      ZdSearch::CLI.start(args, out)
      expect(out.string).to include('No filters specified')
    end

    it 'prints no results found when no search results are found' do
      out = StringIO.new
      ZdSearch::CLI.start(args + ['blah blah'], out)
      expect(out.string).to include('No results found')
    end

    it 'passes in flags as a filter' do
      out = StringIO.new
      expect_any_instance_of(ZdSearch::JSONSearchStore).to receive(:search).with(global: 'query1', 'name' => 'test').and_return([])
      ZdSearch::CLI.start(args + ['query1', '--', 'name=test'], out)
    end

    it 'prints the results as JSON' do
      out = StringIO.new
      ZdSearch::CLI.start(args + ['--', 'priority=high'], out)
      expect(JSON.parse(out.string)).to include('subject' => 'A Catastrophe in Korea (North)')
    end
  end
end
