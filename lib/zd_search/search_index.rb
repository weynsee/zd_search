module ZdSearch
  class SearchIndex
    EMPTY = [].freeze

    def initialize
      @documents = []
      @counter = 0

      # global is a global index
      @global = create_index
      # each field in a document will be stored as an index
      @indices = Hash.new { |hash, key| hash[key] = create_index }
    end

    # Pass in a document to the index
    def <<(document)
      document_id = @counter

      # store the document in a separate store for lookup later
      # the indices would only store the document_id
      @documents << document
      document.each_field do |key, value|
        add_to_index(@global, key, value, document_id)
        add_to_field_index(key, value, document_id)
      end
      @counter += 1
      document
    end

    # Look for a value that can occur in any index
    #
    # ==== Examples
    #
    #   index = SearchIndex.new
    #   index << Document.new(:type, { a: 'test' })
    #   index << Document.new(:type, { b: 'test' })
    #   index.find_any('test') # this will return the 2 documents
    def find_any(value)
      fetch_documents { find_in(@global, value) }
    end

    # Look for a value that occurs in a specific index/field
    #
    # ==== Examples
    #
    #   index = SearchIndex.new
    #   index << Document.new(:type_1, { a: 'test' })
    #   index << Document.new(:type_2, { b: 'test' })
    #   index.find(:a, 'test') # this will return the first document only
    def find(field, value)
      fetch_documents { find_ids(field, value) }
    end

    # Search for documents matching multiple fields.
    # Documents will only be returned if they satisfy all criteria.
    # If +:global+ is passed as a key in options, the value will
    # be matched across all the indices (see *find_any* for an example).
    #
    # ==== Examples
    #
    #   index = SearchIndex.new
    #   index << Document.new(:type, { a: 'test', b: 3 })
    #   index << Document.new(:type, { a: 'test', c: 2 })
    #   index << Document.new(:type, { a: 'test', b: 2 })
    #   index.search(a: 'test', b: 2) # this will return the last document only
    def search(options = {})
      fetch_documents do
        options.map do |filter, value|
          if filter == :global
            find_in(@global, value)
          else
            find_ids(filter, value)
          end
        end.inject(:&).flatten
      end
    end

    def size
      @counter
    end

    private

    def fetch_documents
      load_documents yield
    end

    def add_to_field_index(key, value, document_id)
      index = @indices[key.to_s]
      add_to_index(index, key, value, document_id)
    end

    def add_to_index(index, key, value, document_id)
      if value.respond_to? :each_pair
        value.each_pair do |nested_key, val|
          key = "#{key}.#{nested_key}"
          add_to_field_index(key, val, document_id)
        end
      elsif value.respond_to? :each
        value.each { |val| add_to_index(index, key, val, document_id) }
      else
        index[value.to_s] << document_id
      end
    end

    def load_documents(ids)
      ids.uniq.map { |id| @documents[id] }
    end

    def find_ids(index_name, value)
      index = @indices[index_name.to_s]
      return EMPTY if index.empty?
      find_in(index, value)
    end

    def find_in(index, value)
      index[value.to_s]
    end

    def create_index
      Hash.new { |hash, key| hash[key] = [] }
    end
  end
end
