module Mumukit
  module Bridge
    class Bibliotheca
      attr_accessor :url

      def initialize(url = 'http://bibliotheca.mumuki.io')
        @url = url
      end

      def guides
        get('guides')['guides']
      end

      def books
        get('books')['books']
      end

      def topics
        get('topics')['topics']
      end

      def guide(slug)
        get "guides/#{slug}"
      end

      def book(slug)
        get "books/#{slug}"
      end

      def get(path)
        JSON.parse RestClient.get("#{url}/#{path}")
      end
    end
  end
end