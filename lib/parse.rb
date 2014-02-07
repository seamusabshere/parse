require "parse/version"

require 'date'
require 'yaml'
require 'safe_yaml/load'

module Parse
  # only need to deal with stuff not caught by YAML or JSON
  NULL = [ '', '-', '?', 'N/A', 'n/a', 'NULL', 'null', '#REF!', '#NAME?', 'NIL', 'nil', 'NA', 'na', '#VALUE!', '#NULL!'] # from bigml's list
  NAN = [ 'NaN' ]
  INFINITY = [ '#DIV/0', 'Infinity' ]
  NEG_INFINITY = [ '-Infinity' ]
  DATE = {
    euro: ['%d-%m-%Y', '%d-%m-%y'],
    us:   ['%m-%d-%Y', '%m-%d-%y'],
  }

  def self.parse(raw, options = nil)
    ver0 raw, options
  end

  # @private
  # use YAML to parse stuff like '1.5'
  # ruby's yaml is 1.1, which means it does weird stuff with '001' (fixed in 1.2, which jruby has)
  def self.ver0_0_1(raw, options = nil)
    return raw unless raw.is_a? String
    
    memo = raw.strip
  
    return nil if NULL.include? memo
    return 1.0/0 if INFINITY.include? memo
    return -1.0/0 if NEG_INFINITY.include? memo
    return 0.0/0 if NAN.include? memo
    
    if options and options[:date]
      yyyy, yy = DATE.fetch options[:date]
      memo.sub!(/0+/, '')
      memo.gsub! '/', '-'
      if memo =~ /\d{4,}/ # yyyy
        return Date.strptime(memo, yyyy)
      else
        return Date.strptime(memo, yy)
      end
    end

    not_numeric = nil
    not_numeric ||= memo =~ /,\d{1,2},/ # comma not used for thousands, like 10,20,30
    not_numeric ||= memo =~ /\..*,/ # comma following a period, like 1.0,2
    not_numeric ||= memo =~ /\A[^(+\-\$0-9%]/ # starts with letter or smth
    possible_numeric = !not_numeric
    accounting_negative = nil
    percentage = nil

    if possible_numeric
      accounting_negative = memo =~ /\A[0$]*\([0$]*/
      percentage = memo.end_with?('%')
      memo.sub! /%\z/, '' if percentage
      memo.delete!('()') if accounting_negative # accounting negative
      # in yaml 1.1, anything starting with zero is treated as octal... in 1.2, it's 0o
      memo.sub!(/0+/, '') if memo =~ /\A[+\-]?0+[+\-\$]?[1-9]+/ # leading zeros
      memo.delete!('$') if memo =~ /\A[+\-]?0*\$/
      if memo.include?(',')
        a, b = memo.split('.', 2)
        a.delete! ','
        memo = b ? [a, b].join('.') : a
      end
    end

    not_safe_for_yaml = nil
    not_safe_for_yaml ||= memo.include?('#')
    not_safe_for_yaml ||= not_numeric && memo =~ /\A[\d,]+\z/ #1,2,3, maybe a csv
    safe_for_yaml = !not_safe_for_yaml

    if safe_for_yaml
      begin
        memo = SafeYAML.load memo
      rescue
        $stderr.puts "#{memo.inspect} => #{$!}"
      end
    end

    if possible_numeric
      case memo
      when /\A[+\-]?[\d._]+[eE][+\-]?[\d._]+\z/
        # scientific notation
        memo = memo.to_f
      when /\A[+\-]?0o/
        # octal per yaml 1.2
        memo = memo.to_i 8
      end
    end
    
    if memo.is_a?(String)
      # compress whitespace
      memo.gsub! /\s+/, ' '
    end

    memo = memo / 100.0 if percentage
    memo = -memo if accounting_negative
    memo
  end
end
