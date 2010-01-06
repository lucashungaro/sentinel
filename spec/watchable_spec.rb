require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/my_observer')
require File.expand_path(File.dirname(__FILE__) + '/fixtures/subject')

describe "Watchable" do
  context "defining an observer for a method" do
    
    context "with the minimum required options" do
      before(:all) do
        Subject.send(:include, Watchable)
      end

      it "should notify the specified Observer when calling a class method" do
        Subject.send(:observe, :instance_method, :notify => MyObserver)
        MyObserver.expects(:notify)

        Subject.new.instance_method
      end
      
      it "should notify the specified Observer when calling an instance method" do
        Subject.send(:observe, :class_method, :notify => MyObserver, :class_method => true)
        MyObserver.expects(:notify)
        
        Subject.class_method
      end
    end
    
    context "without the minimum required options" do
      before(:all) do
        Subject.send(:include, Watchable)
      end

      it "should notify the specified Observer when calling a class method" do
        MyObserver.expects(:notify).never
        Subject.expects(:observe).raises(ArgumentError)
        
        Subject.send(:observe, :instance_method) rescue nil
      end

      it "should notify the specified Observer when calling an instance method" do
        MyObserver.expects(:notify).never
        Subject.expects(:observe).raises(ArgumentError)
        
        Subject.send(:observe, :class_method, :class_method => true) rescue nil
      end
    end
    
  end

end
