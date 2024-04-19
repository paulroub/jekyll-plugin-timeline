# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/jekyll-timeline/formatter'

describe(Jekyll::Timeline::Formatter) do
  let(:overrides) { {} }
  let(:config) do
    Jekyll.configuration(Jekyll::Utils.deep_merge_hashes({
                                                           'full_rebuild' => true,
                                                           'source' => source_dir,
                                                           'destination' => dest_dir,
                                                           'show_drafts' => false,
                                                           'url' => 'http://example.org',
                                                           'name' => 'My awesome site',
                                                           'author' => {
                                                             'name' => 'Dr. Jekyll'
                                                           },
                                                           'timeline' => {
                                                             'source' => 'spec/fixtures/rickroll.csv'
                                                           }
                                                         }, overrides))
  end
  let(:site)     { Jekyll::Site.new(config) }
  let(:context)  { make_context(site:) }
  let(:jekyll_env) { 'development' }

  before(:each) do
    allow(Jekyll).to receive(:env).and_return(jekyll_env)
    site.process
  end

  it 'outputs lone text as a paragraph' do
    doc = Nokogiri::HTML::DocumentFragment.parse '<div></div>'

    Nokogiri::HTML::Builder.with(doc.at_css('div')) do |ctr|
      Jekyll::Timeline::Formatter.format_extra(ctr, { 'text' => 'Hello, world!' })
    end

    output = doc.at_css('div').to_html

    expect(output).to eq('<div><p>Hello, world!</p></div>')
  end

  it 'outputs lone link as link text' do
    doc = Nokogiri::HTML::DocumentFragment.parse '<div></div>'

    Nokogiri::HTML::Builder.with(doc.at_css('div')) do |ctr|
      Jekyll::Timeline::Formatter.format_extra(ctr, { 'link' => 'http://example.com/' })
    end

    output = doc.at_css('div').to_html.gsub("\n", '')

    expect(output).to eq('<div><div><h3 class="jekyll-timeline-link"><a href="http://example.com/">http://example.com/</a></h3></div></div>')
  end

  it 'outputs link title if known' do
    doc = Nokogiri::HTML::DocumentFragment.parse '<div></div>'

    Nokogiri::HTML::Builder.with(doc.at_css('div')) do |ctr|
      Jekyll::Timeline::Formatter.format_extra(ctr, { 'link' => 'http://example.com/', 'title' => 'Foo' })
    end

    output = doc.at_css('div').to_html.gsub("\n", '')

    expect(output).to eq('<div><div><h3 class="jekyll-timeline-link"><a href="http://example.com/">Foo</a></h3></div></div>')
  end

  it 'outputs link title and description' do
    doc = Nokogiri::HTML::DocumentFragment.parse '<div></div>'

    Nokogiri::HTML::Builder.with(doc.at_css('div')) do |ctr|
      Jekyll::Timeline::Formatter.format_extra(ctr,
                                               { 'link' => 'http://example.com/', 'title' => 'Foo',
                                                 'description' => 'Desc' })
    end

    output = doc.at_css('div').to_html.gsub("\n", '')

    expect(output).to eq('<div><div><h3 class="jekyll-timeline-link"><a href="http://example.com/">Foo</a></h3><p class="jekyll-timeline-description">Desc</p></div></div>')
  end

  it 'outputs link, image, and description' do
    doc = Nokogiri::HTML::DocumentFragment.parse '<div></div>'

    Nokogiri::HTML::Builder.with(doc.at_css('div')) do |ctr|
      Jekyll::Timeline::Formatter.format_extra(ctr,
                                               { 'link' => 'http://example.com/', 'title' => 'Foo', 'description' => 'Desc',
                                                 'image' => 'http://example.com/image.jpg' })
    end

    output = doc.at_css('div').to_html.gsub("\n", '')

    expect(output).to eq('<div><div class="jekyll-timeline-image-box"><a href="http://example.com/"><img src="http://example.com/image.jpg" class="jekyll-timeline-image"></a></div><div><h3 class="jekyll-timeline-link"><a href="http://example.com/">Foo</a></h3><p class="jekyll-timeline-description">Desc</p></div></div>')
  end

  it 'formats an id for an entry' do
    entry = { 'date' => Date.new(2020, 1, 1), 'summary' => 'Foo bar, baz' }

    expect(Jekyll::Timeline::Formatter.format_id(entry)).to eq('2020-01-01-foo-bar-baz')
  end

  it 'ignores leading/trailing space' do
    entry = { 'date' => Date.new(2020, 1, 1), 'summary' => ' Foo bar, baz  ' }

    expect(Jekyll::Timeline::Formatter.format_id(entry)).to eq('2020-01-01-foo-bar-baz')
  end

  it 'truncates long id for an entry' do
    entry = { 'date' => Date.new(2020, 1, 1),
              'summary' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.' }

    expect(Jekyll::Timeline::Formatter.format_id(entry)).to eq('2020-01-01-lorem-ipsum-dolor-si')
  end
end
