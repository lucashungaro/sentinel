class Subject
  def instance_method
    "hi from instance method!"
  end
  
  def self.class_method
    "hi from class method!"
  end
  
  def instance_method_with_params(*params)
    "hi from instance method with params!"
  end
  
  def self.class_method_with_params(*params)
    "hi from class method with params!"
  end
  
  def instance_returning_something
    42
  end
  
  def self.class_returning_something
    42
  end
end