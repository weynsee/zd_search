require 'json'

module ZdSearch
  class JSONSearchStore
    def initialize(dir)
      @search_index = SearchIndex.new
      load_files(dir)
    end

    def size
      @search_index.size
    end

    def search(options = {})
      @search_index.search(options)
    end

    private

    def load_files(dir)
      path = File.join(dir, '*.json')
      Dir[path].each do |file|
        if File.file?(file) && File.extname(file) == '.json'
          load_file file
        end
      end
    end

    def load_file(file)
      type = File.basename file, '.json'
      File.open(file) do |f|
        JSON.load(f).each do |doc|
          document = Document.new(type, doc)
          @search_index << document
        end
      end
    end
  end
end
