# -*- coding: utf-8 -*-
require 'uri'
require 'opengraph'
require 'nokogiri'
require 'MeCab'

def expand_url(url)
  url = URI(url)
  http = Net::HTTP.new(url.host, url.port)
  url.port
  http.start() {|http|
    response = http.head(url.request_uri)
    case response
    when Net::HTTPRedirection
      expand_url(response['location'])
    else
      return url
    end
  }
end

class Entry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :title, type: String
  field :words, type: Hash

  has_many :bookmarks

  def fetch
    begin
      url = expand_url(self.url)
      http = Net::HTTP.new(url.host, url.port)
      if url.port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = http.start() {|io|
        io.get(url.request_uri)
      }
    rescue => e
      p e
    end

    # self.title = 'untitled'
    if response and response['content-type'] =~ /text\/html/
      content = response.body
      if content and og = OpenGraph.parse(content)
        self.title = og['title']
      end
      if content
        doc = Nokogiri::HTML.parse(content)
        self.title = doc.css('title').text
        doc.css('script').remove
        doc.css('style').remove
        text = doc.css('body').text.gsub(/\n/, '').gsub(/\s+/, ' ')
        mecab = MeCab::Tagger.new( "-O wakati" )
        node = mecab.parseToNode(text.encode('utf-8'))
        bow = {}
        while node
          if node.feature.force_encoding('utf-8') =~ /名詞,一般/
            surface = node.surface
            if bow.include? surface
              bow[surface] += 1
            else
              bow[surface] = 1
            end
          end
          node = node.next
        end

        self.words = bow.symbolize_keys
      end
    end

    self.save
  end
end
