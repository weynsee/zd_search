module ZdSearch
  class SearchIndex
    EMPTY = [].freeze

    def initialize
      @documents = {}
      index = Hash.new { |hash, key| hash[key] = [] }
      @counter = 0
      @indices = Hash.new { |hash, key| hash[key] = index }
    end

    def <<(document)
      @counter += 1
      document_id = "#{document.type}-#{@counter}"
      @documents[document_id] = document
      document.each_field do |key, value|
        key = key.to_s
        index = @indices[key]
        if value.respond_to? :each
          value.each { |val| index[val] << document_id }
        else
          index[value] << document_id
        end
      end
      document
    end

    def find(index_name, value)
      ids = find_ids(index_name, value)
      load_documents(ids)
    end

    def search(options = {})
      ids = options.map do |filter, value|
        find_ids(filter, value)
      end.inject(:&)
      load_documents(ids)
    end

    def size
      @counter
    end

    private

    def load_documents(ids)
      ids.map { |id| @documents[id] }
    end

    def find_ids(index_name, value)
      index = @indices[index_name.to_s]
      return EMPTY if index.empty?
      index[value].uniq
    end
  end
end
