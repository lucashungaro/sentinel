module Watchable
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def observe(method_name, options = {})
      unless options[:notify]
        raise ArgumentError.new("You should provide the :notify option")
      end
      body = <<-CODE
        define_method "#{method_name}_with_observer" do |*args|
          options[:notify].notify(*args)
          self.send("#{method_name}_without_observer", *args)
        end

        alias_method "#{method_name}_without_observer", method_name
        alias_method method_name, "#{method_name}_with_observer"
      CODE
      
      if options[:class_method]

        metaclass = class << self; self; end

        metaclass.instance_eval do
          eval body
        end
        
      else
        eval body
      end
    end
  end
end