require 'spec_helper'

describe Mumukit::Bridge::Runner do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://foo', 10, foo: 'bar') }

  describe 'importable_info' do
    before { expect(bridge).to receive(:info).and_return(response) }

    context 'when language is non-graphical' do
      let(:response) { {
        'name' => 'ruby',
        'version' => 'master',
        'escualo_base_version' => nil,
        'escualo_service_version' => nil,
        'mumukit_version' => '1.0.1',
        'output_content_type' => 'markdown',
        'features' => {
            'query' => true,
            'expectations' => false,
            'feedback' => false,
            'secure' => false,
            'sandboxed' => true,
            'stateful' => true,
            'structured' => true
        },
        'language' => {
            'prompt' => '>',
            'name' => 'ruby',
            'version' => '2.0',
            'extension' => 'rb',
            'ace_mode' => 'ruby'
        },
        'test_framework' => {
            'name' => 'rspec',
            'version' => '2.13',
            'test_extension' => '.rb'
        },
        'url' => 'http://ruby.runners.mumuki.io/info'
      } }

      it { expect(bridge.importable_info).to json_eq name: "ruby",
                                                      comment_type: nil,
                                                      test_runner_url: "http://foo",
                                                      output_content_type: "markdown",
                                                      prompt: "> ",
                                                      extension: "rb",
                                                      highlight_mode: "ruby",
                                                      visible_success_output: false,
                                                      devicon: nil,
                                                      triable: false,
                                                      feedback: false,
                                                      queriable: true,
                                                      multifile: false,
                                                      stateful_console: true,
                                                      test_extension: ".rb",
                                                      test_template: nil,
                                                      layout_js_urls: [],
                                                      layout_html_urls: [],
                                                      layout_css_urls: [],
                                                      editor_js_urls: [],
                                                      editor_html_urls: [],
                                                      editor_css_urls: [],
                                                      layout_shows_loading_content: false,
                                                      editor_shows_loading_content: false}
    end

    context 'when language is graphical' do
      let(:response) { {
        'name' => 'gobstones',
        'version' => 'master',
        'escualo_base_version' => nil,
        'escualo_service_version' => nil,
        'mumukit_version' => '1.0.1',
        'output_content_type' => 'html',
        'features' => {
            'query' => false,
            'expectations' => true,
            'feedback' => true,
            'secure' => false,
            'sandboxed' => false,
            'structured' => true
        },
        'layout_assets_urls' => {
            'js' => ['javascripts/a.js'],
            'html' => ['b.html', 'c.html'],
            'css' => ['stylesheets/d.css']
        },
        'editor_assets_urls' => {
            'js' => ['javascripts/aa.js'],
            'html' => ['bb.html', 'cc.html'],
            'css' => ['stylesheets/dd.css'],
            'shows_loading_content' => true
        },
        'language' => {
            'name' => 'gobstones',
            'graphic' => true,
            'version' => '1.4.1',
            'extension' => 'gbs',
            'ace_mode' => 'gobstones'
        },
        'test_framework' => {
            'name' => 'stones-spec',
            'test_extension' => 'yml'
        },
        'url' => 'http://runners2.mumuki.io:8001/info'  } }

      it { expect(bridge.importable_info).to json_eq name: "gobstones",
                                                    comment_type: nil,
                                                    test_runner_url: "http://foo",
                                                    output_content_type: "html",
                                                    prompt: "ム ",
                                                    extension: "gbs",
                                                    highlight_mode: "gobstones",
                                                    visible_success_output: true,
                                                    devicon: nil,
                                                    triable: false,
                                                    feedback: true,
                                                    queriable: false,
                                                    multifile: false,
                                                    stateful_console: false,
                                                    test_extension: "yml",
                                                    test_template: nil,
                                                    layout_js_urls: ["http://foo/javascripts/a.js"],
                                                    layout_html_urls: ["http://foo/b.html", "http://foo/c.html"],
                                                    layout_css_urls: ["http://foo/stylesheets/d.css"],
                                                    editor_js_urls: ["http://foo/javascripts/aa.js"],
                                                    editor_html_urls: ["http://foo/bb.html", "http://foo/cc.html"],
                                                    editor_css_urls: ["http://foo/stylesheets/dd.css"],
                                                    layout_shows_loading_content: false,
                                                    editor_shows_loading_content: true}
    end

    context 'when language has multifile feature' do
      let(:response) {
        {
          'name' => 'java',
          'version' => '1.7.1',
          'escualo_base_version' => 'v79',
          'escualo_service_version' => nil,
          'mumukit_version' => '2.32.0',
          'output_content_type' => 'markdown',
          'features' => {
              'query' => false,
              'expectations' => true,
              'feedback' => true,
              'secure' => false,
              'multifile' => true,
              'sandboxed' => true,
              'structured' => true
          },
          'language' => {
              'name' => 'java',
              'version' => 'openjdk-8',
              'extension' => 'java',
              'ace_mode' => 'java'
          },
          'test_framework' => {
              'name' => 'junit',
              'test_extension' => 'java'
          },
          'url' => 'https://java.runners.mumuki.io/info'
        }
      }

      it {
        expect(bridge.importable_info).to json_eq name: "java",
                                                  comment_type: nil,
                                                  test_runner_url: "http://foo",
                                                  output_content_type: "markdown",
                                                  prompt: "ム ",
                                                  extension: "java",
                                                  highlight_mode: "java",
                                                  visible_success_output: false,
                                                  devicon: nil,
                                                  triable: false,
                                                  feedback: true,
                                                  queriable: false,
                                                  multifile: true,
                                                  stateful_console: false,
                                                  test_extension: "java",
                                                  test_template: nil,
                                                  layout_js_urls: [],
                                                  layout_html_urls: [],
                                                  layout_css_urls: [],
                                                  editor_js_urls: [],
                                                  editor_html_urls: [],
                                                  editor_css_urls: [],
                                                  layout_shows_loading_content: false,
                                                  editor_shows_loading_content: false}
    end
  end

  describe 'headers' do
    it { expect(bridge.headers).to eq foo: 'bar' }
  end
end
