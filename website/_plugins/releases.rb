require 'json'
require 'hash-joiner'
require 'html/pipeline'
require 'unirest'

module Releases
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    def initialize(config = {})
      @filter = HTML::Pipeline::MentionFilter.new(
        nil,
        base_url: config['mention-baseurl']
      )
    end

    def generate(site)
      config = site.config['releases']
      return unless config
      repo = config['repository']
      return unless repo

      if ENV['GITHUB_TOKEN']
        Unirest.default_header(
          'Authorization', "token #{ENV['GITHUB_TOKEN']}"
        )
      end

      begin
        uri = "https://api.github.com/repos/#{repo}/releases?per_page=100'"
        source = Unirest.get(uri)
        source = source.body

        source = source.map do |release|
          asset = if release['assets'].first
                    a = release['assets'].first
                    {
                      'url' => a['browser_download_url'],
                      'size' => a['size']
                    }
                  else
                    {}
                  end

          {
            'name' => release['name'],
            'version' => release['tag_name'].try(:gsub, /^v/, ''),
            'date' => release['published_at'] || release['created_at'],
            'notes' => format_notes(release['body']),
            'sparkle' => extract_sparkle(release['body']),
            'asset' => asset
          }
        end

        source = source.select { |r| r['sparkle']['signature'] }

        if site.data['releases']
          HashJoiner.deep_merge site.data['releases'], source
        else
          site.data['releases'] = source
        end

        # path = '_data/releases.json'
        # open(path, 'wb') do |file|
        #   file << JSON.generate(site.data['releases'])
        # end
      rescue StandardError => e
        raise e
      end
    end

    def format_notes(body)
      @filter.mention_link_filter(
        body, nil, nil, HTML::Pipeline::MentionFilter::UsernamePattern
      )
    end

    def extract_sparkle(body)
      signature = body.match(%r{<!-- SPARKLESIG2 ([\w=\/]+) -->})
      signature = signature ? signature[1] : nil

      minimum_version = body.match(/<!-- SPARKLEMINVER (\w+) -->/)
      minimum_version = minimum_version ? minimum_version[1] : '10.9'

      {
        'signature' => signature,
        'minimum_version' => minimum_version
      }
    end
  end
end
