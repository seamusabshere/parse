require 'spec_helper'
require 'twitter_cldr'

describe Parse::Algorithm::Ver0_1_0 do
  same = [
    '1,2',
    '1,20',
    '1,2.0',
    '-1,2',
    '-1,20',
    '-1,2.0',
    '01,2',
    '01,20',
    '01,2.0',
    '15_000',
    '15_00_0',
    '15_000.0',
    '15_00_0.0',
    '0_015.0', # just weird
    '1_2.5e-1_3',
    '-1_2.5e-1_3',
    '$123_456',
    '$123_456.7',
    '-15_000',
    '-15_00_0',
    '-15_000.0',
    '-15_00_0.0',
    '0_0-15.0', # just weird
    '-$123_456',
    '($123_456)',
    '-$123_456.7',
    '($123_456.7)',
    '10_14_A',
    '10_14',
    '10_140',
  ]
  same.each do |v|
    it "parses #{v.inspect} as itself (yaml=#{SafeYAML.load(v).inspect})" do
      expect(Parse.ver0_1_0(v)).to eq(v)
    end
  end

  a = {

    "@ foo"                            => "@ foo",
    ", foo"                            => ", foo",
    "044-1-276-000"                    => "044-1-276-000",

    ['1 BEDROOMS', { type: Numeric } ] => 1,
    '1 BEDROOMS'                       => '1 BEDROOMS',

    [ '2.4 SQFT', { type: Numeric } ]  => 2.4,
    '2.4 SQFT'                         => '2.4 SQFT',

    ['000', { date: :us, ignore_error: true}] => nil,
    ['7/7/2004', {date: :us}]           => Date.new(2004,7,7),
    "999 HOLY CROSS ROAD, COLCHESTER, VT 05446" => "999 HOLY CROSS ROAD, COLCHESTER, VT 05446",

    '00020110628'                      => 20110628,
    '0002011-06-28'                    => Date.new(2011,6,28),
    '0002011/06/28'                    => Date.new(2011,6,28),
    ['00020110628', {date: :iso}]      => Date.new(2011,6,28),
    ['00020110628', {type: Date}]      => Date.new(2011,6,28),

    '00019800628'                      => 19800628,
    '0001980-06-28'                    => Date.new(1980,6,28),
    '0001980/06/28'                    => Date.new(1980,6,28),
    ['00019800628', {date: :iso}]      => Date.new(1980,6,28),
    ['00019800628', {type: Date}]      => Date.new(1980,6,28),

    '00030000628'                      => 30000628,
    '0003000-06-28'                    => '0003000-06-28',
    '0003000/06/28'                    => '0003000/06/28',
    ['00030000628', {date: :iso}]      => Date.new(3000,6,28),
    ['00030000628', {type: Date}]      => Date.new(3000,6,28),

    ['', {type: Numeric}]              => nil,

    # fortran double precision
    '0.225120000000000D+06'            => 0.22512e6,
    '0.341913000000000D+07'            => 0.341913e7,
    '0.2500000E-01'                    => 0.25e-1,
    '3.1D0'                            => 3.1,
    '-2.D0'                            => -2.0,

    '8e-05'                            => 8e-5,
    '8e+4'                             => 8e4,
    '8.0e+4'                           => 8.0e4,
    '8e-4'                             => 8e-4,
    '8.0e-4'                           => 8.0e-4,
    '-8e+4'                            => -8e4,
    '-8.0e+4'                          => -8.0e4,
    '-8e-4'                            => -8e-4,
    '-8.0e-4'                          => -8.0e-4,
    '8E+4'                             => 8e4,
    '8.0E+4'                           => 8.0e4,
    '8E-4'                             => 8e-4,
    '8.0E-4'                           => 8.0e-4,
    '-8E+4'                            => -8e4,
    '-8.0E+4'                          => -8.0e4,
    '-8E-4'                            => -8e-4,
    '-8.0E-4'                          => -8.0e-4,

    # http://dojotoolkit.org/reference-guide/1.9/dojo/number.html
    # '1,000,000.00'                     => 1_000_000.0,
    # '1.000.000,00'                     => 1_000_000.0, # german
    # '1 000 000,00'                     => 1_000_000.0, # french
    # '10,00,000.00'                     => 1_000_000.0, # indian

    '060-10-01'                        => '60-10-01',
    'OFF'                              => 'OFF',
    'ON'                               => 'ON',

    '& P4'                             => '& P4',

    # EVERYTHING BELOW IS SAME AS 0.0.1
    
    ''                                 => nil,
    'nil'                              => nil,
    '15'                               => 15,
    '15,000'                           => 15_000,
    '15.0'                             => 15.0,
    '15,000.0'                         => 15_000.0,
    '0015'                             => 15,   # not octal
    '0015.0'                           => 15.0,  # not octal
    '0x15'                             => 0x15, # hex
    '0o15'                             => 015,  # octal
    '8e-05'                            => 8e-05,
    '12.5e-13'                       => 12.5e-13,
    '-12.5e-13'                      => -12.5e-13,
    '$123.4'                           => 123.4,
    '0$123.4'                           => 123.4,
    '$15,000'                          => 15_000,
    '0$15,000'                          => 15_000,
    '10,000,000'                       => 10_000_000,
    '10,000,000.00'                    => 10_000_000.0,
    '$10,000,000.00'                    => 10_000_000.0,
    '0$10,000,000.00'                    => 10_000_000.0,
    '$010,000,000.00'                    => 10_000_000.0,

    '-15'                              => -15,
    '-15,000'                          => -15_000,
    '-15.0'                            => -15.0,
    '-15,000.0'                        => -15_000.0,
    '00-15'                            => -15,   # not octal
    '00-15.0'                          => -15.0,  # not octal
    '-0x15'                            => -0x15, # hex
    '-0o15'                            => -015,  # octal
    '-8e-05'                           => -8e-05,
    '-$123.4'                          => -123.4,
    '($123.4)'                         => -123.4,
    '0($123.4)'                        => -123.4,
    '-$15,000'                         => -15_000,
    '($15,000)'                        => -15_000,
    '-$123456'                        => -123_456,
    '($123456)'                       => -123_456,
    '-$123456.7'                      => -123_456.7,
    '($123456.7)'                     => -123_456.7,
    '-$123,456'                        => -123_456,
    '($123,456)'                       => -123_456,
    '-$123,456.7'                      => -123_456.7,
    '($123,456.7)'                     => -123_456.7,
    '-10,000,000'                      => -10_000_000,
    '(10,000,000)'                     => -10_000_000,
    '-10,000,000.00'                   => -10_000_000.0,
    '(10,000,000.00)'                  => -10_000_000.0,
    '-10000000'                        => -10_000_000,
    '(10000000)'                       => -10_000_000,
    '-10000000.00'                     => -10_000_000.0,
    '(10000000.00)'                    => -10_000_000.0,
    '1,200'                            => 1_200,
    '1,200.0'                          => 1_200.0,
    '1.0,2'                            => '1.0,2',
    '1.0,2.0'                          => '1.0,2.0',
    '-1,200'                           => -1_200,
    '-1,200.0'                         => -1_200.0,
    '-1.0,2'                           => '-1.0,2',
    '-1.0,2.0'                         => '-1.0,2.0',
    '01,200'                           => 1_200,
    '01,200.0'                         => 1_200.0,
    '01.0,2'                           => '01.0,2',
    '01.0,2.0'                         => '01.0,2.0',

    '05753'                            => 5753,
    'true'                             => true,
    'yes'                              => true,
    'false'                            => false,
    'no'                               => false,
    '#DIV/0'                           => (1.0/0),
    '#NAME?'                           => nil,
    'Inf'                              => 'Inf',
    'Infinity'                         => (1.0/0),
    '-Infinity'                        => -(1.0/0),
    'NaN'                              => 0.0/0, # need the dot
    '.NaN'                             => 0.0/0,  # NaN
    '-.inf'                            => -(1.0/0), # -Infinity
    '-'                                => nil, # per bigml
    '?'                                => nil,
    '1982-01-01'                       => Date.new(1982,1,1),
    '2010-05-05 13:42:16 Z'            => Time.parse('2010-05-05 13:42:16 Z'),
    '2010-05-05 13:42:16 -02:00'       => Time.parse('2010-05-05 13:42:16 -02:00'),
    ":not_a_symbol"                    => ':not_a_symbol',
    '#hello'                           => '#hello',
    "\n#hello\n#world"                 => '#hello #world',
    "hello\nworld"                     => 'hello world', # whitespace compression

    '0%'                               => 0.0,
    '100%'                             => 1.0,
    '50%'                              => 0.5,
    '5%'                               => 0.05,
    '00000%'                           => 0.0,
    '0000100%'                         => 1.0,
    '000050%'                          => 0.5,
    '00005%'                           => 0.05,

    ['12/25/82', {date: :us}]          => Date.new(1982,12,25),
    ['12/25/1982', {date: :us}]        => Date.new(1982,12,25),
    ['25/12/82', {date: :euro}]        => Date.new(1982,12,25),
    ['25/12/1982', {date: :euro}]      => Date.new(1982,12,25),
    ['12-25-82', {date: :us}]          => Date.new(1982,12,25),
    ['12-25-1982', {date: :us}]        => Date.new(1982,12,25),
    ['25-12-82', {date: :euro}]        => Date.new(1982,12,25),
    ['25-12-1982', {date: :euro}]      => Date.new(1982,12,25),

    '12/25/82'                         => '12/25/82',

    ',1'                               => ',1', # not a csv parser
    ',1,'                              => ',1,', # not a csv parser
    '1,2,3'                            => '1,2,3', # not a csv parser
    '[1,2,3]'                          => [1,2,3],
    YAML.dump('a' => 1)                => { 'a' => 1 },
    YAML.dump(a: 1)                    => { ':a' => 1 }, # doesn't parse symbols
    YAML.dump('a' => 1, 5 => "c\n3")   => { 'a' => 1, 5 => "c\n3" },
    MultiJson.dump(a: 1)               => { 'a' => 1 }, # json always loses symbols
    MultiJson.dump(a: 1, 5 => "c\n3")  => { 'a' => 1, '5' => "c\n3" },
  }

  # TwitterCldr.supported_locales.each do |locale|
  #   1.upto(9).map do |power|
  #     num = (rand * (10 ** power)).round(4)
  #     # a[[num.localize(locale).to_s, {locale: locale}]] = num
  #     a[[num.localize(locale).to_s, { locale: locale }]] = num
  #     # a[num.localize(locale).to_currency.to_s] = num
  #   end
  # end

  # and next dates!
  # Time.now.localize(:es).to_full_s

  a.each do |input, expected|
    input = Array.wrap input
    locale = if input[1].is_a?(Hash)
      input[1][:locale]
    end
    it "#{locale ? "(#{locale}) " : nil}parses #{input[0].inspect} as #{expected.inspect}" do
      got = Parse.ver0_1_0(*input)
      # $lines << [ "Parse.parse(#{input.inspect})".ljust(45), "#=> #{got.inspect}" ].join
      if expected.is_a?(Float) and expected.nan?
        expect(got.nan?).to eq(true)
      elsif expected.is_a?(Float) and got.is_a?(Float)
        expect(got.round(8)).to eq(expected.round(8))
      else
        expect(got).to eq(expected)
      end

      input_with_spaces = [ "\t" + input[0] + "\t", input[1] ]
      got_with_spaces = Parse.ver0_1_0(*input_with_spaces)
      if expected.is_a?(Float) and expected.nan?
        expect(got.nan?).to eq(true)
      elsif expected.is_a?(Float) and got.is_a?(Float)
        expect(got.round(8)).to eq(expected.round(8))
      else
        expect(got_with_spaces).to eq(expected)
      end
    end
  end
end
