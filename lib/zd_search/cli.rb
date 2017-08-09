module ZdSearch
  class CLI
    # CLI entry point
    #
    # * +:args+ - An array of command-line arguments and flags (usually ARGV)
    # * +:out+ - Output stream where the results will be printed (usually STDOUT)
    def self.start(args = ARGV, out = STDOUT)
      config = FlagParser.parse(args)
      formatter = JSONFormatter.new(out)
      store = JSONSearchStore.new(config.data_dir)
      filters = config.filters
      filters.merge!(global: config.query) if config.query
      if filters.empty?
        formatter.puts 'No filters specified. Pass -h to see usage'
        return
      end
      results = store.search(filters)
      if results.empty?
        formatter.puts 'No results found'
        return
      end
      results.each do |doc|
        formatter.format doc
      end
    end
  end
end
