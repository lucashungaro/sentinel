class SentinelSubject
  def instance_method
    42
  end

  def self.class_method
    42
  end

  def instance_method_with_params(*params)
    "hi from instance method with params!"
  end

  def self.class_method_with_params(*params)
    "hi from class method with params!"
  end
end