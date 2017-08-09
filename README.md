# ZdSearch

ZdSearch is a command line ruby application that searches through JSON files and returns matching
results.

## Installation

### Docker

A dockerfile is provided for running the app with all the dependencies included. To build the image:

    $ docker build -t zd_search .

And then to run it:

    $ docker run --rm -it zd_search

Here's an example of running it with some filters and using an external data directory located in the host OS:

    $ docker run --rm -ti -v ~/path/to/data:/data zd_search -d /data -- domain_names=kage.com

### Locally

Prerequisites:

1. Ruby 2.0 and above
2. Bundler

Run `bin/setup` to install dependencies. Then run it using:

    $ exe/zd_search

You can also install it locally as a gem. To install this gem onto your local machine, run `bundle exec rake install`.
The `zd_search` command should be available after.

## Usage

`zd_search` requires a data directory to search against. This directory must contain valid JSON files with `.json` extensions,
otherwise they will be ignored. If no directory is specified, it will check for a `data` directory relative to its current path.
To specify a data directory, do:

    $ zd_search -d <directory>

To search for a particular field, you can specify filters after `--` and in the format
`name=value`. For example:

    $ zd_search -- published=true org_count=50 # will only match JSON objects where published key has the value true, and org_count has the value 50
    $ zd_search -- name= # will only match JSON objects where name is blank or null

JSON objects will only match if they contain all the given fields and their corresponding values.
You can specify nested fields by separating
them with dots:

    $ zd_search -- published.location=Singapore

To search against all JSON values, simply pass it in as an argument without flags. For example:

    $ zd_search "Miss Livingston"
    $ zd_search Colleen

All the flags and options can be combined together:

    $ zd_search -d data_folder "Match this against all JSON values" -- tags=Nebraska published=true

Usage information is also available via the `-h` option.

## Tests

Tests can be run using `rake spec` or `rspec`.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ZdSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/weynsee/zd_search/blob/master/CODE_OF_CONDUCT.md).
