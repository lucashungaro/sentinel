require "metaid"

module Sentinel
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def observe(class_name, method_name, options = {})
      sentinel = self

      options = {
        :method_to_notify => :notify,
        :intercept => :after
      }.merge(options)

      if options[:intercept] == :before
        calls = <<-CODE
          sentinel.send("#{options[:method_to_notify]}", observer_opt, *args)
          self.send("#{method_name}_without_observer", *args)
        CODE
      else
        calls = <<-CODE
          result = self.send("#{method_name}_without_observer", *args)
          observer_opt[:result] = result
          sentinel.send("#{options[:method_to_notify]}", observer_opt, *args)
          result
        CODE
      end

      body = <<-CODE
        define_method "#{method_name}_with_observer" do |*args|
          observer_opt = {:subject => self}
          #{calls}
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