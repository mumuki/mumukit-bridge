module Mumukit
  module Bridge
    class Thesaurus
      attr_accessor :url

      def initialize(url)
        @url = url
      end

      def runners
        @runners ||= JSON.parse(get('runners'))['runners']
      end

      private

      def get(resource)
        RestClient.get("#{url}/#{resource}")
      end
    end
  end
end