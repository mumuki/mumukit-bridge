module Mumukit
  module Bridge
    class Bibliotheca
      attr_accessor :url, :headers

      def initialize(test_runner_url, timeout=10, headers={})
        @test_runner_url = test_runner_url
        @timeout = timeout
        @headers = headers
      end

      def guides
        get_collection 'guides'
      end

      def topics
        get_collection 'topics'
      end

      def books
        get_collection 'books'
      end

      def guide(slug)
        get_element 'guides', slug
      end

      def topic(slug)
        get_element 'topics', slug
      end

      def book(slug)
        get_element 'books', slug
      end

      def get_collection(name)
        get(name)[name]
      end

      def get_element(name, slug)
        get "#{name}/#{slug}"
      end

      def get(path)
        JSON.parse RestClient.get("#{url}/#{path}", self.headers)
      end
    end
  end
end