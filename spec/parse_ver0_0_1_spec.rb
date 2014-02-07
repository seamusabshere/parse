require 'spec_helper'

require 'multi_json'
require 'active_support/core_ext'

$lines = []

describe Parse do
  it 'should have a version number' do
    Parse::VERSION.should_not be_nil
  end

  {
    ''                                 => nil,
    'nil'                              => nil,
    '15'                               => 15,
    '15,000'                           => 15_000,
    '15_000'                           => 15_000,
    '15_00_0'                          => 15_000,
    '15.0'                             => 15.0,
    '15,000.0'                         => 15_000.0,
    '15_000.0'                         => 15_000.0,
    '15_00_0.0'                        => 15_000.0,
    '0015'                             => 15,   # not octal
    '0015.0'                           => 15.0,  # not octal
    '0_015.0'                          => 15.0, # just weird
    '0x15'                             => 0x15, # hex
    '0o15'                             => 015,  # octal
    '8e-05'                            => 8e-05,
    '1_2.5e-1_3'                       => 12.5e-13,
    '$123.4'                           => 123.4,
    '0$123.4'                           => 123.4,
    '$15,000'                          => 15_000,
    '0$15,000'                          => 15_000,
    '$123_456'                         => 123_456,
    '$123_456.7'                       => 123_456.7,
    '10,000,000'                       => 10_000_000,
    '10,000,000.00'                    => 10_000_000.0,
    '$10,000,000.00'                    => 10_000_000.0,
    '0$10,000,000.00'                    => 10_000_000.0,
    '$010,000,000.00'                    => 10_000_000.0,

    '-15'                              => -15,
    '-15,000'                          => -15_000,
    '-15_000'                          => -15_000,
    '-15_00_0'                         => -15_000,
    '-15.0'                            => -15.0,
    '-15,000.0'                        => -15_000.0,
    '-15_000.0'                        => -15_000.0,
    '-15_00_0.0'                       => -15_000.0,
    '00-15'                            => -15,   # not octal
    '00-15.0'                          => -15.0,  # not octal
    '0_0-15.0'                         => '0_0-15.0', # just weird
    '-0x15'                            => -0x15, # hex
    '-0o15'                            => -015,  # octal
    '-8e-05'                           => -8e-05,
    '-1_2.5e-1_3'                      => -12.5e-13,
    '-$123.4'                          => -123.4,
    '($123.4)'                         => -123.4,
    '0($123.4)'                        => -123.4,
    '-$15,000'                         => -15_000,
    '($15,000)'                        => -15_000,
    '-$123_456'                        => -123_456,
    '($123_456)'                       => -123_456,
    '-$123_456.7'                      => -123_456.7,
    '($123_456.7)'                     => -123_456.7,
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
    '1,2'                              => 12,
    '1,20'                             => 120,
    '1,2.0'                            => 12.0,
    '1.0,2'                            => '1.0,2',
    '1.0,2.0'                          => '1.0,2.0',
    '-1,200'                           => -1_200,
    '-1,200.0'                         => -1_200.0,
    '-1,2'                             => -12,
    '-1,20'                            => -120,
    '-1,2.0'                           => -12.0,
    '-1.0,2'                           => '-1.0,2',
    '-1.0,2.0'                         => '-1.0,2.0',
    '01,200'                           => 1_200,
    '01,200.0'                         => 1_200.0,
    '01,2'                             => 12,
    '01,20'                            => 120,
    '01,2.0'                           => 12.0,
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
  }.each do |input, expected|
    it "parses #{input.inspect} as #{expected.inspect}" do
      input = Array.wrap input
      got = Parse.ver0_0_1(*input)
      # $lines << [ "Parse.parse(#{input.inspect})".ljust(45), "#=> #{got.inspect}" ].join
      if expected.is_a?(Float) and expected.nan?
        expect(got.nan?).to eq(true)
      else
        expect(got).to eq(expected)
      end

      input_with_spaces = [ "\t" + input[0] + "\t", input[1] ]
      got_with_spaces = Parse.ver0_0_1(*input_with_spaces)
      if expected.is_a?(Float) and expected.nan?
        expect(got.nan?).to eq(true)
      else
        expect(got_with_spaces).to eq(expected)
      end
    end
  end
end

at_exit do
  $lines.each do |line|
    $stderr.puts line
  end
end
