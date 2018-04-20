require_relative './runner/response_type'
require_relative './runner/array'
require_relative './runner/boolean'


module Mumukit
  module Bridge
    class Runner
      attr_accessor :test_runner_url, :timeout, :headers

      def initialize(test_runner_url, timeout=10, headers={})
        @test_runner_url = test_runner_url
        @timeout = timeout
        @headers = headers
      end

      # Expects a hash
      #  {test: string, extra: string, content: string, expectations: [{binding:string, inspection: string})]}
      # Returns a hash
      #   {result: string,
      #    test_results: [{title:string, status:symbol, result:string}],
      #    status: :passed|:failed|:errored|:aborted|:passed_with_warnings,
      #    expectation_results: [{binding:string, inspection:string, result:symbol}],
      #    feedback: string}
      def run_tests!(request)
        with_server_response request, 'test' do |response|
          response_type = ResponseType.for_response response
          response_type.parse response
        end
      end

      # Expects a hash
      #  {query: string, extra: string, content: string}
      # Returns a hash
      #   {result: string,
      #    status: :passed|:failed|:errored|:aborted}
      def run_query!(request)
        with_server_response request, 'query' do |it|
          {status: it['exit'].to_sym, result: it['out']}
        end
      end

      def run_try!(request)
        with_server_response request, 'try' do |it|
          {
            status: it['exit'].to_sym,
            result: it['out'],
            query_result: it['queryResult'].try do |it|
              { status: it['status'].to_sym,
                result: it['result'] }
            end
          }
        end
      end

      def importable_info
        @language_json ||= info.merge('url' => test_runner_url)
        {
          name:                   @language_json['name'],
          comment_type:           @language_json['comment_type'],
          test_runner_url:        @language_json['url'],
          output_content_type:    @language_json['output_content_type'],
          prompt:                (@language_json.dig('language', 'prompt') || 'ム') + ' ',
          extension:              @language_json.dig('language', 'extension'),
          highlight_mode:         @language_json.dig('language', 'ace_mode'),
          visible_success_output: @language_json.dig('language', 'graphic').present?,
          devicon:                @language_json.dig('language', 'icon', 'name'),
          triable:                @language_json.dig('features', 'try').present?,
          feedback:               @language_json.dig('features', 'feedback').present?,
          queriable:              @language_json.dig('features', 'query').present?,
          stateful_console:       @language_json.dig('features', 'stateful').present?,
          test_extension:         @language_json.dig('test_framework', 'test_extension'),
          test_template:          @language_json.dig('test_framework', 'template'),
          layout_js_urls:         get_assets_for(:layout, 'js'),
          layout_html_urls:       get_assets_for(:layout, 'html'),
          layout_css_urls:        get_assets_for(:layout, 'css'),
          editor_js_urls:         get_assets_for(:editor, 'js'),
          editor_html_urls:       get_assets_for(:editor, 'html'),
          editor_css_urls:        get_assets_for(:editor, 'css')
        }
      end

      def assets(path, options={})
        raw_get_to_server "assets/#{path}", options
      end

      def info(options={})
        JSON.parse raw_get_to_server(:info, options.merge(content_type: :json))
      end

      def with_server_response(request, route, &action)
        response = post_to_server(request, route)
        action.call(response)
      rescue Exception => e
        {result: e.message, status: :aborted}
      end

      def raw_get_to_server(route, options)
        RestClient.get("#{test_runner_url}/#{route}", options)
      end

      def post_to_server(request, route)
        JSON.parse RestClient::Request.new(
                       method: :post,
                       url: "#{test_runner_url}/#{route}",
                       payload: request.to_json,
                       timeout: @timeout,
                       open_timeout: @timeout,
                       headers: {content_type: :json}).execute()
      end

      private

      def get_assets_for(kind, content_type)
        absolutize(@language_json.dig("#{kind}_assets_urls", content_type) || [])
      end

      def absolutize(urls)
        urls.map { |url| "#{test_runner_url}/#{url}"}
      end
    end
  end
end
