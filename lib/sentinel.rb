require "metaid"

module Sentinel
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def observe(class_name, method_name, options = {})
      sentinel = self

      body = <<-CODE
        define_method "#{method_name}_with_observer" do |*args|
          sentinel.notify(*args)
          self.send("#{method_name}_without_observer", *args)
        end

        alias_method "#{method_name}_without_observer", method_name
        alias_method method_name, "#{method_name}_with_observer"
      CODE

      if options[:class_method]
        class_name.meta_eval do
          eval body
        end
      else
        class_name.send(:class_eval, body)
      end
    end
  end
end