require 'json'

module ZdSearch
  class JSONFormatter
    def initialize(out)
      @out = out
    end

    def puts(string)
      @out.puts string
    end

    def format(document)
      @out.puts JSON.pretty_generate(document.body)
    end
  end
end
