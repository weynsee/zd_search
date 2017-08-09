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

  def pluck(documents, field)
    documents.map { |doc| doc.body[field] }
  end

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

  describe '#find_any' do
    context 'not found' do
      let(:documents) { [ZdSearch::Document.new(:thing, name: 'Clark')] }

      it 'returns empty array' do
        expect(search.find_any('Kent')).to be_empty
      end
    end

    context 'found' do
      let(:documents) do
        [
          ZdSearch::Document.new(:thing, id: 1, name: 'Bruce'),
          ZdSearch::Document.new(:thing_1, id: 2, name: 'Wayne'),
          ZdSearch::Document.new(:thing_2, id: 3,name: 'Selina', last_name: 'Wayne'),
          ZdSearch::Document.new(:thing_3, id: 4, name: 'Kyle'),
        ]
      end

      it 'returns all matches' do
        results = search.find_any('Wayne')
        expect(pluck(results, :id)).to contain_exactly(3, 2)
      end
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
        results = search.find('name', 'Clark')
        expect(pluck(results, :name)).to contain_exactly('Clark')
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
          results = search.find(:name, 'Clark')
          expect(results.size).to eq 2
        end
      end

      context 'restricted to field' do
        let(:documents) do
          [
            ZdSearch::Document.new(:thing_0, name: 'Clark', id: 2),
            ZdSearch::Document.new(:thing_1, name: 'Kent', _uid: 2),
          ]
        end

        it 'returns only documents with matching field' do
          results = search.find('_uid', 2)
          expect(pluck(results, :name)).to contain_exactly 'Kent'
        end
      end
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
        results = search.find('status', true)
        expect(pluck(results, :name)).to contain_exactly 'Clark'
      end
    end

    context 'int' do
      let(:documents) do
        [
          ZdSearch::Document.new(:thing, name: 'Clark', _id: 123),
          ZdSearch::Document.new(:thing, name: 'Kent', _id: 123456),
        ]
      end

      it 'returns matching document' do
        results = search.find_any(123)
        expect(pluck(results, :name)).to contain_exactly 'Clark'
      end
    end

    context 'hash' do
      let(:documents) do
        [
          ZdSearch::Document.new(:thing, id: 1, obj: 3),
          ZdSearch::Document.new(:thing, id: 2, obj: { a: { b: 3 }}),
        ]
      end

      it 'returns matching document' do
        results = search.find('obj.a.b', 3)
        expect(pluck(results, :id)).to contain_exactly 2
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
        results = search.find('tags', 'DC')
        expect(pluck(results, :name)).to contain_exactly('Clark', 'Leonard')
      end

      context 'nested hash' do
        let(:documents) do
          [
            ZdSearch::Document.new(:thing, name: 'Clark', obj: [{ nest: 'nested', b: 2}]),
            ZdSearch::Document.new(:thing, name: 'Leonard', obj: %w[DC villain]),
          ]
        end

        it 'returns matching document' do
          results = search.find('obj.nest', 'nested')
          expect(pluck(results, :name)).to contain_exactly 'Clark'
        end
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
        results = search.find('last_name', '')
        expect(pluck(results, :name)).to contain_exactly 'Bruce'
      end

      it 'matches nil too' do
        results = search.find('last_name', nil)
        expect(pluck(results, :name)).to contain_exactly 'Bruce'
      end
    end

    context 'nil' do
      let(:documents) do
        [
          ZdSearch::Document.new(:thing, name: 'Clark', last_name: 'Kent'),
          ZdSearch::Document.new(:thing, name: 'Bruce', last_name: nil),
        ]
      end

      it 'returns matching document' do
        results = search.find(:last_name, nil)
        expect(pluck(results, :name)).to contain_exactly 'Bruce'
      end

      it 'matches empty string too' do
        results = search.find('last_name', '')
        expect(pluck(results, :name)).to contain_exactly 'Bruce'
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
      expect(pluck(results, :name)).to contain_exactly 'Diana'
    end
  end
end
