require File.dirname(__FILE__) + '/../spec_helper'

describe PachubeDataFormats::SearchResult do

  it "should have a constant that defines the allowed keys" do
    PachubeDataFormats::SearchResult::ALLOWED_KEYS.should == %w(totalResults startIndex itemsPerPage feeds)
  end


  context "attr accessors" do
    before(:each) do
      @search_result = PachubeDataFormats::SearchResult.new(:feeds => [feed_as_(:json), feed_as_(:hash)])
    end

    describe "setting whitelisted fields" do
      PachubeDataFormats::SearchResult::ALLOWED_KEYS.each do |key|
        it "##{key}=" do
          lambda {
            @search_result.send("#{key}=", key)
          }.should_not raise_error
        end
      end
    end

    describe "getting whitelisted fields" do
      PachubeDataFormats::SearchResult::ALLOWED_KEYS.each do |key|
        it "##{key}" do
          lambda {
            @search_result.send(key)
          }.should_not raise_error
        end
      end
    end

    describe "setting non-whitelisted keys" do
      it "should not be possible to set non-whitelisted fields" do
        lambda {
          @search_result.something_bogus = 'whatevs'
        }.should raise_error
      end

      it "should not be possible to get non-whitelisted fields" do
        lambda {
          @search_result.something_bogus
        }.should raise_error
      end
    end
  end

  describe "#initialize" do
    it "should require one parameter" do
      lambda{PachubeDataFormats::SearchResult.new}.should raise_exception(ArgumentError, "wrong number of arguments (0 for 1)")
    end

    it "should accept a hash of attributes" do
      search_result = PachubeDataFormats::SearchResult.new("totalResults" => 1000, "feeds" => [feed_as_(:hash)])
      search_result.totalResults.should == 1000
      search_result.feeds.length.should == 1
    end
  end

  describe "#attributes" do
    it "should return a hash of search result properties" do
      attrs = {}
      PachubeDataFormats::SearchResult::ALLOWED_KEYS.each do |key|
        attrs[key] = "key #{rand(1000)}"
      end
      attrs["feeds"] = [PachubeDataFormats::Feed.new({"id" => "ein"})]
      search_result = PachubeDataFormats::SearchResult.new(attrs)

      search_result.attributes.should == attrs
    end

    it "should not return nil values" do
      attrs = {}
      PachubeDataFormats::SearchResult::ALLOWED_KEYS.each do |key|
        attrs[key] = "key #{rand(1000)}"
      end
      attrs["totalResults"] = nil
      search_result = PachubeDataFormats::Feed.new(attrs)

      search_result.attributes.should_not include("totalResults")
    end
  end

  describe "#attributes=" do
    it "should accept and save a hash of feed properties" do
      search_result = PachubeDataFormats::SearchResult.new({})

      attrs = {}
      PachubeDataFormats::SearchResult::ALLOWED_KEYS.each do |key|
        value = "key #{rand(1000)}"
        attrs[key] = value
        search_result.should_receive("#{key}=").with(value)
      end
      search_result.attributes=(attrs)
    end
  end

  context "associated feeds" do

    describe "#feeds" do
      it "should return an array of feeds" do
        feeds = [PachubeDataFormats::Feed.new(feed_as_(:hash))]
        attrs = {"feeds" => feeds}
        feed = PachubeDataFormats::SearchResult.new(attrs)
        feed.feeds.each do |env|
          env.should be_kind_of(PachubeDataFormats::Feed)
        end
      end
    end

    describe "#feeds=" do
      before(:each) do
        @search_result = PachubeDataFormats::SearchResult.new({})
      end

      it "should return nil if not an array" do
        @search_result.feeds = "kittens"
        @search_result.feeds.should be_nil
      end

      it "should accept an array of feeds and hashes and store an array of datastreams" do
        new_feed1 = PachubeDataFormats::Feed.new(feed_as_(:hash))
        new_feed2 = PachubeDataFormats::Feed.new(feed_as_(:hash))
        PachubeDataFormats::Feed.should_receive(:new).with(feed_as_(:hash)).and_return(new_feed2)

        feeds = [new_feed1, feed_as_(:hash)]
        @search_result.feeds = feeds
        @search_result.feeds.length.should == 2
        @search_result.feeds.should include(new_feed1)
        @search_result.feeds.should include(new_feed2)
      end

      it "should accept an array of feeds and store an array of feeds" do
        feeds = [PachubeDataFormats::Feed.new(feed_as_(:hash))]
        @search_result.feeds = feeds
        @search_result.feeds.should == feeds
      end

      it "should accept an array of hashes and store an array of feeds" do
        new_feed = PachubeDataFormats::Feed.new(feed_as_(:hash))
        PachubeDataFormats::Feed.should_receive(:new).with(feed_as_(:hash)).and_return(new_feed)

        feeds_hash = [feed_as_(:hash)]
        @search_result.feeds = feeds_hash
        @search_result.feeds.should == [new_feed]
      end
    end

  end

  # Provided by PachubeDataFormats::Templates::SearchResultDefaults
  describe "#generate_json" do
    it "should take a version and generate the appropriate template" do
      search_result = PachubeDataFormats::SearchResult.new({})
      PachubeDataFormats::Template.should_receive(:new).with(search_result, :json)
      lambda {search_result.generate_json("1.0.0")}.should raise_error(NoMethodError)
    end
  end

  describe "#to_xml" do
    it "should call the xml generator with default version" do
      search_result = PachubeDataFormats::SearchResult.new({})
      search_result.should_receive(:generate_xml).with("0.5.1").and_return("<xml></xml>")
      search_result.to_xml.should == "<xml></xml>"
    end

    it "should accept optional xml version" do
      version = "5"
      search_result = PachubeDataFormats::SearchResult.new({})
      search_result.should_receive(:generate_xml).with(version).and_return("<xml></xml>")
      search_result.to_xml(:version => version).should == "<xml></xml>"
    end
  end

  describe "#as_json" do
    it "should call the json generator with default version" do
      search_result = PachubeDataFormats::SearchResult.new({})
      search_result.should_receive(:generate_json).with("1.0.0").and_return({"title" => "Feed"})
      search_result.as_json.should == {"title" => "Feed"}
    end

    it "should accept optional json version" do
      version = "0.6-alpha"
      search_result = PachubeDataFormats::SearchResult.new({})
      search_result.should_receive(:generate_json).with(version).and_return({"title" => "Feed"})
      search_result.as_json(:version => version).should == {"title" => "Feed"}
    end
  end

  describe "#to_json" do
    it "should call #as_json" do
      search_result_hash = {"totalResults" => 100}
      search_result = PachubeDataFormats::SearchResult.new(search_result_hash)
      search_result.should_receive(:as_json).with({})
      search_result.to_json
    end

    it "should pass options through to #as_json" do
      search_result_hash = {"totalResults" => 100}
      search_result = PachubeDataFormats::SearchResult.new(search_result_hash)
      search_result.should_receive(:as_json).with({:crazy => "options"})
      search_result.to_json({:crazy => "options"})
    end

    it "should generate feeds" do
      search_result = PachubeDataFormats::SearchResult.new("feeds" => [feed_as_('hash')])
      search_result.feeds = feed_as_(:hash)
      JSON.parse(search_result.to_json)["results"].should_not be_nil
    end

    it "should pass the output of #as_json to yajl" do
      search_result_hash = {"totalResults" => 100}
      search_result = PachubeDataFormats::SearchResult.new(search_result_hash)
      search_result.should_receive(:as_json).and_return({:awesome => "hash"})
      ::JSON.should_receive(:generate).with({:awesome => "hash"})
      search_result.to_json
    end
  end
end
