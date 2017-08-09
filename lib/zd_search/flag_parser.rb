require 'optparse'

module ZdSearch
  class FlagParser
    def self.parse(args)
      config = OpenStruct.new
      # Set the default values here
      config.data_dir = 'data'
      config.filters = {}
      config.query = nil

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: zd_search [options] [query] [-- [filters]]"

        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-d", "--data-dir DIRECTORY",
                "Directory where the data files reside",
                "Data files must contain JSON and have a .json extension") do |dir|
          config.data_dir = dir
        end

        opts.separator ""
        opts.separator "Query is a string that will be searched against all JSON values."
        opts.separator "Passing it in is optional."

        opts.separator ""
        opts.separator "Filters are specified after --."
        opts.separator "They are used to restrict the search to specific JSON keys."
        opts.separator "They must follow the format of NAME=VALUE."
        opts.separator ""
        opts.separator "Example:"
        opts.separator "zd_search -- active=true published_count=5"

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail('-v', "--version", "Show current version") do
          puts ZdSearch::VERSION
          exit
        end
      end
      parser.parse!(args)
      parse_filters(config, args)
      config
    end

    def self.parse_filters(config, args)
      first_arg = args.first
      if first_arg && first_arg.index('=').nil?
        config.query = args.shift
      end
      args.each do |arg|
        if arg.index('=').nil?
          warn "unrecognized option #{arg}, skipping"
          next
        end
        key, value = arg.split('=')
        config.filters[key] = value
      end
      config
    end

    private_class_method :parse_filters
  end
end
