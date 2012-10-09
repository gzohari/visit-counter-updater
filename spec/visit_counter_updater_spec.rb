require "spec_helper"

class DummyObject
  include VisitCounter

  attr_accessor :counter

  def update_attribute(attribute, value)
    self.send("#{attribute}=", value)
  end

  def read_attribute(name)
    #yeah, evals are evil, but it works and it's for testing purposes only. we assume read_attribute is defined the same as in AR wherever we include this module
    eval("@#{name}")
  end
end

VisitCounter::Store::RedisStore.redis = Redis.new(host: "localhost")
VisitCounter::Store::RedisStore.redis.flushdb

describe VisitCounter do
  describe "updating counters for the given time-period (disregarding threshold)" do
    let(:d_key) {"visit_counter::DummyObject::1::counter"}
    let(:d1_key) {"visit_counter::DummyObject::2::counter"}
    let(:set_name) {"visit_counter::DummyObject::counter"}

    before :each do
      @d, @d1 = DummyObject.new, DummyObject.new
      @d.stub(:id).and_return(1)
      @d1.stub(:id).and_return(2)
      DummyObject.stub(:transaction).and_yield
      @d.nullify_counter_cache(:counter)
      VisitCounter::Store.engine.redis.del set_name
      @d.increase_counter
      @d1.increase_counter
    end

    it "should update multiple objects" do
      DummyObject.stub(:where).and_return([@d, @d1])
      DummyObject.should_receive(:update_all).once.with("counter = 1", "id = 1").ordered
      DummyObject.should_receive(:update_all).once.with("counter = 1", "id = 2").ordered
      DummyObject.update_counters(:counter, (Time.now - 4))
    end

    it "should only find counter hits from the given time-period" do
      VisitCounter::Store.engine.redis.zincrby(set_name, -100000, d1_key)
      VisitCounter::Store.engine.get_all_by_range(set_name, (Time.now - 20).to_i, Time.now.to_i).should == [d_key]
    end

    it "should not try to update counters without objects" do
      VisitCounter::Store.engine.should_receive(:get_all_by_range).and_return([d_key, d1_key])
      DummyObject.stub(:where).and_return([@d])
      VisitCounter::Helper.stub(:merge_array_values).and_return([0])
      DummyObject.should_receive(:update_all).once
      DummyObject.update_counters(:counter, (Time.now - 4))
    end
  end

end

