module Parse
  module Algorithm
    # only need to deal with stuff not caught by YAML or JSON
    NAN = [ 'NaN' ]
    INFINITY = [ '#DIV/0', 'Infinity' ]
    NEG_INFINITY = [ '-Infinity' ]
  end
end
