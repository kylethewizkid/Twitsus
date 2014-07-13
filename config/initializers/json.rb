# as_json uses to_hash, a deprecated method. Thus I had to fix manually

class Object
  def as_json(options = nil) #:nodoc:
    if respond_to?(:to_hash)
      to_h.as_json(options)
    else
      instance_values.as_json(options)
    end
  end
end