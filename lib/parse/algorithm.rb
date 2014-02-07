module Parse
  module Algorithm
    # only need to deal with stuff not caught by YAML or JSON
    NULL = [ '', '-', '?', 'N/A', 'n/a', 'NULL', 'null', '#REF!', '#NAME?', 'NIL', 'nil', 'NA', 'na', '#VALUE!', '#NULL!'] # from bigml's list
    NAN = [ 'NaN' ]
    INFINITY = [ '#DIV/0', 'Infinity' ]
    NEG_INFINITY = [ '-Infinity' ]
    DATE = {
      euro: ['%d-%m-%Y', '%d-%m-%y'],
      us:   ['%m-%d-%Y', '%m-%d-%y'],
    }
  end
end
