if String.method_defined?(:blank_as?)
  class String
    alias blank? blank_as?
  end
end
