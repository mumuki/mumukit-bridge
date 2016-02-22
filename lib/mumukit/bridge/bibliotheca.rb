module Mumukit
  module Bridge
    class Bibliotheca
      def initialize(url = 'http://bibliotheca.mumuki.io')
        @url = url
      end

      def guides
        get('guides')['guides']
      end

      def books
        get('books')['books']
      end

      def runners
        get('runners')['runners']
      end

      def languages
        get('languages')['languages']
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