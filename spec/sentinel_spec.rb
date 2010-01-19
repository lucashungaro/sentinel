require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/my_observer')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/sentinel_subject')

describe Sentinel, "defining an observer for a method" do
  before(:all) do
    SentinelSubject.send(:include, Sentinel)
  end
  
  context "with the minimum required options" do
    it "should notify the specified Observer when calling a class method" do
      SentinelSubject.send(:observe, :instance_method, :notify => MyObserver)
      MyObserver.expects(:notify)

      SentinelSubject.new.instance_method
    end
    
    it "should notify the specified Observer when calling an instance method" do
      SentinelSubject.send(:observe, :class_method, :notify => MyObserver, :class_method => true)
      MyObserver.expects(:notify)
      
      SentinelSubject.class_method
    end
    
    it "should not modify the observed methods output" do
      SentinelSubject.send(:observe, :class_returning_something, :notify => MyObserver, :class_method => true)
      SentinelSubject.send(:observe, :instance_returning_something, :notify => MyObserver)
      
      MyObserver.expects(:notify).twice

      SentinelSubject.class_returning_something.should == 42
      SentinelSubject.new.instance_returning_something.should == 42
    end
    
    context "observing methods with parameters" do
      it "should pass all parameters of the observed methods to the Observer" do
        SentinelSubject.send(:observe, :class_method_with_params, :notify => MyObserver, :class_method => true)
        SentinelSubject.send(:observe, :instance_method_with_params, :notify => MyObserver)

        MyObserver.expects(:notify).twice.with("texto", 1)

        SentinelSubject.class_method_with_params("texto", 1)
        SentinelSubject.new.instance_method_with_params("texto", 1)
      end
    end
  end
  
  context "without the minimum required options" do
    it "should raise ArgumentError when the observer of an instance method is not defined" do
      MyObserver.expects(:notify).never
      SentinelSubject.expects(:observe).raises(ArgumentError)
      
      SentinelSubject.send(:observe, :instance_method) rescue nil
    end

    it "should raise ArgumentError when the observer of a class method is not defined" do
      MyObserver.expects(:notify).never
      SentinelSubject.expects(:observe).raises(ArgumentError)
      
      SentinelSubject.send(:observe, :class_method, :class_method => true) rescue nil
    end
  end
end