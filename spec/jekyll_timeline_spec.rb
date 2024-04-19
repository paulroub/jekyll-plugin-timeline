# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/jekyll-timeline/parser'

describe(TimelinePlugin) do
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

  let(:csv_file) { config['timeline']['source'] }
  let(:csv_data) { CSV.table(csv_file) }

  let(:parser) { Jekyll::Timeline::Parser.new(csv_data) }

  before(:each) do
    allow(Jekyll).to receive(:env).and_return(jekyll_env)
    site.process
  end

  it 'reads entries from a CSV file' do
    events = parser.parse

    expect(events.size).to eql(5)
  end

  it 'sorts the timeline' do
    events = parser.parse

    dates = events.map { |event| event['date'] }

    expect(dates).to eq(dates.sort)
  end

  it 'finds the summary' do
    events = parser.parse

    expect(events[0]['summary']).to eq('"Never Gonna Give You Up" released')
  end

  it 'finds the extras' do
    events = parser.parse

    expect(events[1]['extras'][0]['text']).to eq('extra text')
    expect(events[3]['extras'][0]['link']).to eq('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
  end

  it 'pulls title from link metadata' do
    events = parser.parse

    expect(events[3]['extras'][0]['title']).to eq('Rick Astley - Never Gonna Give You Up (Official Music Video) - YouTube')
  end

  it 'pulls description from link metadata' do
    events = parser.parse

    expect(events[3]['extras'][0]['description']).to eq('The official video for “Never Gonna Give You Up” by Rick Astley. The new album \'Are We There Yet?\' is out now: Download here: https://RickAstley.lnk.to/AreWe...')
  end

  it 'pulls image from link metadata' do
    events = parser.parse

    expect(events[3]['extras'][0]['image']).to eq('https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg')
  end
end
