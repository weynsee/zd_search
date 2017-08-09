require "spec_helper"

RSpec.describe ZdSearch::SearchIndex do
  let(:search) do
    search = ZdSearch::SearchIndex.new
    documents.each do |doc|
      search << doc
    end
    search
  end

  let(:documents) { [] }

  describe '#size' do
    let(:documents) do
      [
        ZdSearch::Document.new(:thing, name: 'Diana'),
        ZdSearch::Document.new(:thing, name: 'Clark'),
        ZdSearch::Document.new(:thing, name: 'Bruce'),
        ZdSearch::Document.new(:thing, name: 'Arthur')
      ]
    end

    it 'returns the number of documents inside the index' do
      expect(search.size).to eq 4
    end
  end

  describe '#find' do
    context 'not found' do
      let(:documents) { [ZdSearch::Document.new(:thing, name: 'Clark')] }

      it 'returns empty array' do
        expect(search.find('name', 'Kent')).to be_empty
      end
    end

    context 'empty index' do
      it 'returns empty array' do
        expect(search.find('name', 'Kent')).to be_empty
      end
    end

    context 'found' do
      let(:documents) { [ZdSearch::Document.new(:thing, name: 'Clark')] }

      it 'returns the original document' do
        documents = search.find('name', 'Clark')
        expect(documents.size).to eq 1
        expect(documents.first.body[:name]).to eq 'Clark'
      end

      context 'across indices' do
        let(:documents) do
          [
            ZdSearch::Document.new(:thing_0, name: 'Clark', url: 'http://www.example.com'),
            ZdSearch::Document.new(:thing_1, name: 'Clark', status: true),
            ZdSearch::Document.new(:thing_1, name: 'Kent', status: true),
          ]
        end

        it 'returns all matching documents' do
          documents = search.find('name', 'Clark')
          expect(documents.size).to eq 2
        end
      end

      context 'different value types' do
        context 'boolean' do
          let(:documents) do
            [
              ZdSearch::Document.new(:thing, name: 'Clark', status: true),
            ]
          end

          it 'returns matching document' do
            documents = search.find('status', true)
            expect(documents.size).to eq 1
            expect(documents.first.body[:name]).to eq 'Clark'
          end
        end

        context 'array' do
          let(:documents) do
            [
              ZdSearch::Document.new(:thing, name: 'Clark', tags: %w[DC superhero]),
              ZdSearch::Document.new(:thing, name: 'Leonard', tags: %w[DC villain]),
              ZdSearch::Document.new(:thing, name: 'Archie', tags: %w[Archie]),
            ]
          end

          it 'returns matching documents' do
            documents = search.find('tags', 'DC')
            expect(documents.size).to eq 2
            names = documents.map { |doc| doc.body[:name] }
            expect(names).to contain_exactly('Clark', 'Leonard')
          end
        end

        context 'empty' do
          let(:documents) do
            [
              ZdSearch::Document.new(:thing, name: 'Clark', last_name: 'Kent'),
              ZdSearch::Document.new(:thing, name: 'Bruce', last_name: ''),
            ]
          end

          it 'returns matching document' do
            documents = search.find('last_name', '')
            expect(documents.size).to eq 1
            expect(documents.first.body[:name]).to eq 'Bruce'
          end
        end
      end
    end
  end

  describe '#search' do
    let(:documents) do
      [
        ZdSearch::Document.new(:thing, name: 'Diana', active: true, done: 3),
        ZdSearch::Document.new(:thing_1, name: 'Clark', active: false, done: 3),
        ZdSearch::Document.new(:thing, name: 'Bruce', active: false, done: 4),
        ZdSearch::Document.new(:thing_2, name: 'Arthur', active: true, done: 5)
      ]
    end

    it 'searches on multiple attributes' do
      results = search.search(active: true, done: 3)
      expect(results.size).to eq 1
      expect(documents.first.body[:name]).to eq 'Diana'
    end
  end
end
