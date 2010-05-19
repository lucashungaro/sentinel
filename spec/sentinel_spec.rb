require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/my_observer')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/sentinel_subject')

describe Sentinel do
  before(:each) do
    MyObserver.send(:include, Sentinel)
  end
  
  after(:each) do
    # reload the file to undefine the observer methods (would cause 'stack level too deep' errors otherwise)
    load File.expand_path(File.dirname(__FILE__) + '/fixtures/sentinel_subject.rb')    
  end

  context "basic premises" do
    it "should not modify the subject method output when called after it" do
      MyObserver.send(:observe, SentinelSubject, :class_method, :class_method => true)
      MyObserver.send(:observe, SentinelSubject, :instance_method)
      subject = SentinelSubject.new

      MyObserver.expects(:notify).once.with({:result => 42, :subject => subject})
      MyObserver.expects(:notify).once.with({:result => 42, :subject => SentinelSubject})

      SentinelSubject.class_method.should == 42
      subject.instance_method.should == 42
    end
    
    it "should not modify the subject method output when called before it" do
      MyObserver.send(:observe, SentinelSubject, :class_method, :class_method => true, :intercept => :before)
      MyObserver.send(:observe, SentinelSubject, :instance_method, :intercept => :before)
      subject = SentinelSubject.new

      MyObserver.expects(:notify).once.with({:subject => SentinelSubject})
      MyObserver.expects(:notify).once.with({:subject => subject})

      SentinelSubject.class_method.should == 42
      subject.instance_method.should == 42
    end
    
    it "should pass all parameters of the observed methods to the observer" do
      MyObserver.send(:observe, SentinelSubject, :class_method_with_params, :class_method => true)
      MyObserver.send(:observe, SentinelSubject, :instance_method_with_params)

      subject = SentinelSubject.new

      MyObserver.expects(:notify).once.with({:result => 'hi from class method with params!', :subject => SentinelSubject}, "texto", 1)
      MyObserver.expects(:notify).once.with({:result => 'hi from instance method with params!', :subject => subject}, "texto", 1)

      SentinelSubject.class_method_with_params("texto", 1)
      subject.instance_method_with_params("texto", 1)
    end
  end

  context "with the default options" do
    it "should notify the specified observer when calling an instance method" do
      MyObserver.send(:observe, SentinelSubject, :instance_method)
      MyObserver.expects(:notify)

      SentinelSubject.new.instance_method
    end

    it "should notify the specified observer when calling a class method" do
      MyObserver.send(:observe, SentinelSubject, :class_method, :class_method => true)
      MyObserver.expects(:notify)

      SentinelSubject.class_method
    end
    
    it "should be called after the method execution" do
      MyObserver.send(:observe, SentinelSubject, :instance_method)
      subject = SentinelSubject.new
      
      MyObserver.expects(:notify).once.with({:result => 42, :subject => subject})

      subject.instance_method
    end
  end
  
  context "with user-specified options" do
    context "when observing methods using a different observer method" do
      it "should call the specified observer method when the subject method is called" do
        MyObserver.send(:observe, SentinelSubject, :instance_method, :method_to_notify => :another_method)
        MyObserver.send(:observe, SentinelSubject, :class_method, :method_to_notify => :another_method, :class_method => true)
        
        MyObserver.expects(:another_method).twice

        SentinelSubject.new.instance_method
        SentinelSubject.class_method
      end 
    end
    
    context "when intercepting the call after the method execution" do
      it "should pass the result of the execution to the observer" do
        MyObserver.send(:observe, SentinelSubject, :instance_method)
        MyObserver.send(:observe, SentinelSubject, :class_method, :class_method => true)
        
        subject = SentinelSubject.new
        
        MyObserver.expects(:notify).once.with({:subject => subject, :result => 42})
        MyObserver.expects(:notify).once.with({:subject => SentinelSubject, :result => 42})

        subject.instance_method
        SentinelSubject.class_method
      end
    end
  end

end