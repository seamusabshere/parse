# Parse

Detect and convert short strings into integers, floats, dates, times, booleans, arrays, and hashes - "like a human would".

## Note on versions

You can always use `Parse.parse`. It will always point to the most recent version of the algorithm (currently `Parse.ver0_0_1`).

If the algorithm changes and you need the old version, you can reference it by its version number. For example, `Parse.ver0_0_1`.

## Usage

You get the idea:

    Parse.parse("15,000")                        #=> 15000
    Parse.parse("$123.4")                        #=> 123.4
    Parse.parse("(10,000,000.00)")               #=> -10000000.0
    Parse.parse("true")                          #=> true
    Parse.parse("no")                            #=> true
    Parse.parse("1982-01-01")                    #=> Fri, 01 Jan 1982
    Parse.parse("2010-05-05 13:42:16 Z")         #=> 2010-05-05 10:42:16 -0300
    Parse.parse("2010-05-05 13:42:16 -02:00")    #=> 2010-05-05 12:42:16 -0300
    Parse.parse("100%")                          #=> 1.0
    Parse.parse("50%")                           #=> 0.5
    Parse.parse("12/25/82", date: :us)           #=> Sat, 25 Dec 1982
    Parse.parse("25/12/82", date: :euro)         #=> Sat, 25 Dec 1982
    Parse.parse("#DIV/0")                        #=> Infinity
    Parse.parse("")                              #=> nil
    Parse.parse("nil")                           #=> nil
    Parse.parse("#NAME?")                        #=> nil
    Parse.parse("NaN")                           #=> NaN
    Parse.parse(".NaN")                          #=> NaN
    Parse.parse("-.inf")                         #=> -Infinity
    Parse.parse("Inf")                           #=> "Inf"
    Parse.parse(":no_symbols")                   #=> ":no_symbols"

More esoteric stuff:

    Parse.parse("-")                             #=> nil
    Parse.parse("?")                             #=> nil
    Parse.parse("-8e-05")                        #=> -8.0e-05
    Parse.parse("-1_2.5e-1_3")                   #=> -1.25e-12
    Parse.parse("05753")                         #=> 5753
    Parse.parse("15_000")                        #=> 15000
    Parse.parse("15_00_0")                       #=> 15000
    Parse.parse("15.0")                          #=> 15.0
    Parse.parse("15,000.0")                      #=> 15000.0
    Parse.parse("15_000.0")                      #=> 15000.0
    Parse.parse("15_00_0.0")                     #=> 15000.0
    Parse.parse("0015")                          #=> 15
    Parse.parse("0015.0")                        #=> 15.0
    Parse.parse("0_015.0")                       #=> 15.0
    Parse.parse("0x15")                          #=> 21
    Parse.parse("0o15")                          #=> 13
    Parse.parse("8e-05")                         #=> 8.0e-05
    Parse.parse("1_2.5e-1_3")                    #=> 1.25e-12
    Parse.parse("0$123.4")                       #=> 123.4
    Parse.parse("$15,000")                       #=> 15000
    Parse.parse("0$15,000")                      #=> 15000
    Parse.parse("$123_456")                      #=> 123456
    Parse.parse("$123_456.7")                    #=> 123456.7
    Parse.parse("10,000,000")                    #=> 10000000
    Parse.parse("10,000,000.00")                 #=> 10000000.0
    Parse.parse("$10,000,000.00")                #=> 10000000.0
    Parse.parse("0$10,000,000.00")               #=> 10000000.0
    Parse.parse("$010,000,000.00")               #=> 10000000.0
    Parse.parse("-15")                           #=> -15
    Parse.parse("-15,000")                       #=> -15000
    Parse.parse("-15_000")                       #=> -15000
    Parse.parse("-15_00_0")                      #=> -15000
    Parse.parse("-15.0")                         #=> -15.0
    Parse.parse("-15,000.0")                     #=> -15000.0
    Parse.parse("-15_000.0")                     #=> -15000.0
    Parse.parse("-15_00_0.0")                    #=> -15000.0
    Parse.parse("00-15")                         #=> -15
    Parse.parse("00-15.0")                       #=> -15.0
    Parse.parse("0_0-15.0")                      #=> "0_0-15.0"
    Parse.parse("-0x15")                         #=> -21
    Parse.parse("-0o15")                         #=> -13
    Parse.parse("-$123.4")                       #=> -123.4
    Parse.parse("($123.4)")                      #=> -123.4
    Parse.parse("0($123.4)")                     #=> -123.4
    Parse.parse("-$15,000")                      #=> -15000
    Parse.parse("($15,000)")                     #=> -15000
    Parse.parse("-$123_456")                     #=> -123456
    Parse.parse("($123_456)")                    #=> -123456
    Parse.parse("-$123_456.7")                   #=> -123456.7
    Parse.parse("($123_456.7)")                  #=> -123456.7
    Parse.parse("-10,000,000")                   #=> -10000000
    Parse.parse("(10,000,000)")                  #=> -10000000
    Parse.parse("-10,000,000.00")                #=> -10000000.0
    Parse.parse("(10,000,000.00)")               #=> -10000000.0
    Parse.parse("1,200")                         #=> 1200
    Parse.parse("1,200.0")                       #=> 1200.0
    Parse.parse("1,2")                           #=> 12
    Parse.parse("1,20")                          #=> 120
    Parse.parse("1,2.0")                         #=> 12.0
    Parse.parse("1.0,2")                         #=> "1.0,2"
    Parse.parse("1.0,2.0")                       #=> "1.0,2.0"
    Parse.parse("-1,200")                        #=> -1200
    Parse.parse("-1,200.0")                      #=> -1200.0
    Parse.parse("-1,2")                          #=> -12
    Parse.parse("-1,20")                         #=> -120
    Parse.parse("-1,2.0")                        #=> -12.0
    Parse.parse("-1.0,2")                        #=> "-1.0,2"
    Parse.parse("-1.0,2.0")                      #=> "-1.0,2.0"
    Parse.parse("01,200")                        #=> 1200
    Parse.parse("01,200.0")                      #=> 1200.0
    Parse.parse("01,2")                          #=> 12
    Parse.parse("01,20")                         #=> 120
    Parse.parse("01,2.0")                        #=> 12.0
    Parse.parse("01.0,2")                        #=> "01.0,2"
    Parse.parse("01.0,2.0")                      #=> "01.0,2.0"
    Parse.parse("#hello")                        #=> "#hello"
    Parse.parse("\n#hello\n#world")              #=> "#hello #world"
    Parse.parse("hello\nworld")                  #=> "hello world"
    Parse.parse(",1")                            #=> ",1"
    Parse.parse(",1,")                           #=> ",1,"

Note how, for better or worse, it effectively acts as a YAML or JSON parser, but doesn't do CSV:

    Parse.parse("1,2,3")                         #=> "1,2,3"
    Parse.parse("[1,2,3]")                       #=> [1, 2, 3]
    Parse.parse("---\na: 1\n")                   #=> {"a"=>1}
    Parse.parse("---\n:a: 1\n")                  #=> {":a"=>1}
    Parse.parse("---\na: 1\n5: |-\n  c\n  3\n")  #=> {"a"=>1, 5=>"c\n3"}
    Parse.parse("{\"a\":1}")                     #=> {"a"=>1}
    Parse.parse("{\"a\":1,\"5\":\"c\\n3\"}")     #=> {"a"=>1, "5"=>"c\n3"}

## Wishlist

1. allow specifying `date: '%Y/%m/%d'` for strptime
1. allow hinting like `type: Integer` or `type: Date`
1. deprecate this whole thing in favor of YAML 1.2?

## Copyright

2014 Seamus Abshere
