module Mumukit
  module Bridge
    class Thesaurus
      attr_accessor :url

      def initialize(url = 'http://bibliotheca.mumuki.io')
        @url = url
        @language = {}
      end

      def languages
        @languages ||= get('languages')['languages']
      end

      def language(name)
        @language[name] ||= get "languages/#{name}"
      end

      def get(path)
        JSON.parse RestClient.get("#{url}/#{path}")
      end
    end
  end
end