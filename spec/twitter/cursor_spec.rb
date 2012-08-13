require 'helper'

describe Twitter::Cursor do

  describe "#collection" do
    it "returns a collection" do
      collection = Twitter::Cursor.new({:ids => [1, 2, 3, 4, 5]}, :ids, nil, Twitter::Client.new, :follower_ids, {}).collection
      collection.should be_an Array
      collection.first.should be_a Fixnum
    end
  end

  describe "#each" do
    before do
      @client = Twitter::Client.new
      stub_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1", :screen_name => "sferik"}).
        to_return(:body => fixture("id_list.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_get("/1/followers/ids.json").
        with(:query => {:cursor => "1305102810874389703", :screen_name => "sferik"}).
        to_return(:body => fixture("id_list2.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "requests the correct resources" do
      @client.follower_ids("sferik").each{}
      a_get("/1/followers/ids.json").
        with(:query => {:cursor => "-1", :screen_name => "sferik"}).
        should have_been_made
      a_get("/1/followers/ids.json").
        with(:query => {:cursor => "1305102810874389703", :screen_name => "sferik"}).
        should have_been_made
    end
    it "iterates" do
      count = 0
      @client.follower_ids("sferik").each{count += 1}
      count.should == 5993
    end
  end

  describe "#first?" do
    context "when previous cursor equals zero" do
      before do
        @cursor = Twitter::Cursor.new({:previous_cursor => 0}, :ids, nil, Twitter::Client.new, :follower_ids, {})
      end
      it "returns true" do
        @cursor.first?.should be_true
      end
    end
    context "when previous cursor does not equal zero" do
      before do
        @cursor = Twitter::Cursor.new({:previous_cursor => 1}, :ids, nil, Twitter::Client.new, :follower_ids, {})
      end
      it "returns true" do
        @cursor.first?.should be_false
      end
    end
  end

  describe "#last?" do
    context "when next cursor equals zero" do
      before do
        @cursor = Twitter::Cursor.new({:next_cursor => 0}, :ids, nil, Twitter::Client.new, :follower_ids, {})
      end
      it "returns true" do
        @cursor.last?.should be_true
      end
    end
    context "when next cursor does not equal zero" do
      before do
        @cursor = Twitter::Cursor.new({:next_cursor => 1}, :ids, nil, Twitter::Client.new, :follower_ids, {})
      end
      it "returns false" do
        @cursor.last?.should be_false
      end
    end
  end

end
