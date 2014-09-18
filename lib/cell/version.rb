module Cell
  module VERSION
    MAJOR = 4
    MINOR = 0
    TINY  = 0
    PRE   = 'alpha1'

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
  end
end
