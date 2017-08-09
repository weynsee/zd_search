module ZdSearch
  class Document
    def initialize(type, body)
      @type = type
      @body = body.dup.freeze
    end

    def type
      @type
    end

    def each_field(&block)
      @body.each(&block)
    end

    def body
      @body
    end
  end
end
