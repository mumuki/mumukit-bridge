module Mumukit
  module Bridge
    class Bibliotheca
      def initialize(url = 'http://bibliotheca.mumuki.io')
        @url = url
      end

      def guides
        get('guides')['guides']
      end

      def guide(slug)
        get "guides/#{slug}"
      end

      def get(path)
        JSON.parse RestClient.get("http://bibliotheca.mumuki.io/#{path}")
      end

    end


  end
end