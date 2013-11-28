require 'spec_helper'
require 'rakuten_web_service'

describe RWS::Books::Genre do
  let(:endpoint) { 'https://app.rakuten.co.jp/services/api/BooksGenre/Search/20121128' }
  let(:affiliate_id) { 'dummy_affiliate_id' }
  let(:application_id) { 'dummy_application_id' }
  let(:genre_id) { '000' }
  let(:expected_query) do
    {
      :affiliateId => affiliate_id,
      :applicationId => application_id,
      :booksGenreId => genre_id
    }
  end
  let(:expected_json) do
    JSON.parse(fixture('books/genre_search.json'))
  end

  before do
    @expected_request = stub_request(:get, endpoint).
      with(:query => expected_query).
      to_return(:body => expected_json)

    RakutenWebService.configuration do |c|
      c.affiliate_id = affiliate_id
      c.application_id = application_id
    end
  end

  describe '.search' do
    before do
      @genre = RWS::Books::Genre.search(:booksGenreId => genre_id).first
    end

    specify 'call the endpoint once' do
      expect(@expected_request).to have_been_made.once
    end
    specify 'has interfaces like hash' do
      expect(@genre['booksGenreName']).to eq(expected_json['current']['booksGenreName'])
      expect(@genre['genreLevel']).to eq(expected_json['current']['genreLevel'])
    end
    specify 'has interfaces like hash with snake case key' do
      expect(@genre['books_genre_name']).to eq(expected_json['current']['booksGenreName'])
      expect(@genre['genre_level']).to eq(expected_json['current']['genreLevel'])
    end
    specify 'has interfaces to get each attribute' do
      expect(@genre.id).to eq(expected_json['current']['booksGenreId'])
      expect(@genre.name).to eq(expected_json['current']['booksGenreName'])
    end
  end

  describe '.new' do
    let(:genre_id) { '007' }
    let(:expected_json) do
      {
        :current => {
          :booksGenreId => genre_id,
          :booksGenreName => 'DummyGenre',
          :genreLevel => '2'
        }
      }.to_json
    end

    before do
      @genre = RWS::Books::Genre.new(param)
    end

    context 'given a genre id' do
      let(:param) { genre_id }

      specify 'only call endpint only at the first time to initialize' do
        RWS::Books::Genre.new(param)

        expect(@expected_request).to have_been_made.once
      end
    end
  end

  describe '.root' do
    specify 'alias of constructor with the root genre id "000"' do
      RWS::Books::Genre.should_receive(:new).with('000')

      RWS::Books::Genre.root
    end
  end

  describe '#children' do
    context 'When get search method' do
      before do
        @genre = RWS::Books::Genre.search(:booksGenreId => genre_id).first
      end

      specify 'are Books::Genre objects' do
        expect(@genre.children).to be_all { |child| child.is_a? RWS::Books::Genre }
        expect(@genre.children).to be_all do |child|
          expected_json['children'].is_any? { |c| c['booksGenreId'] == child['booksGenreId'] }
        end
      end
    end

    context 'when the genre object has no children information' do
      specify 'call the endpoint to get children' do
        genre = RWS::Books::Genre.new(:booksGenreId => genre_id)
        genre.children

        expect(@expected_request).to have_been_made.once
      end
    end
  end

  describe '#search' do
    before do
      @genre = RWS::Books::Genre.new(:booksGenreId => genre_id)
    end

  end
end
