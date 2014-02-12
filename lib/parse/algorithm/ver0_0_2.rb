module Parse
  module Algorithm
    class Ver0_0_2
      NULL = [ '', '-', '?', 'N/A', 'n/a', 'NULL', 'null', '#REF!', '#NAME?', 'NIL', 'nil', 'NA', 'na', '#VALUE!', '#NULL!', '00/00/00', '0000-00-00'] # from bigml's list
      REGION_DATE_FORMAT = {
        euro: ['%d-%m-%Y', '%d-%m-%y'],
        us:   ['%m-%d-%Y', '%m-%d-%y'],
        iso:  ['%Y-%m-%d', '%y-%m-%d'], # second one is silly
      }
      DATE_DETECT = {
        %r{\A0*[12]\d\d\d[\-/](?:(?:0[1-9])|(?:1[0-2]))[\-/][1-9]\d\z} => :iso, # $1 will be delimiter
      }
      EMPTY_OPTIONS = {}

      attr_reader :raw
      attr_reader :options
      def initialize(raw, options = nil)
        @raw = raw
        @options = options || EMPTY_OPTIONS
      end

      def result
        return raw unless raw.is_a? String
        
        memo = raw.strip
      
        return nil if NULL.include? memo
        return 1.0/0 if INFINITY.include? memo
        return -1.0/0 if NEG_INFINITY.include? memo
        return 0.0/0 if NAN.include? memo

        date_region = if options[:date]
          options[:date]
        else
          catch :hit do
            DATE_DETECT.each do |pattern, date_region|
              # binding.pry if memo.include?('2011-')
              if memo =~ pattern
                throw :hit, date_region
              end
            end
            nil
          end
        end

        if date_region.nil? and options[:type] == Date
          date_region = :iso
        end

        if date_region
          yyyy, yy = REGION_DATE_FORMAT.fetch date_region
          is_yyyy = memo =~ /[1-9]\d\d\d/
          memo.sub! /\A0+/, ''
          memo.gsub! '/', '-'
          if is_yyyy
            if memo.length < 10 and date_region == :iso
              return Date.parse(memo)
            else
              return Date.strptime(memo, yyyy)
            end
          else
            return Date.strptime(memo, yy)
          end
        end

        possible_numeric = nil
        not_numeric = nil
        certain_numeric = nil
        if [Numeric, Integer, Float].include?(options[:type])
          certain_numeric = true
          possible_numeric = true
          not_numeric = false
        else
          not_numeric ||= memo =~ /[1-9][^\d_,%\.)eE]/ # has a dash in the middle
          not_numeric ||= memo =~ /,\d{1,2},/ # comma not used for thousands, like 10,20,30
          not_numeric ||= memo =~ /\..*,/ # comma following a period, like 1.0,2
          not_numeric ||= memo.scan(/\D/).length > memo.scan(/\d/).length
          not_numeric ||= memo =~ /\A[^(+\-\$0-9%]/ # starts with letter or smth
          possible_numeric = !not_numeric
        end
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

        # binding.pry if memo =~ /sqft/i
        if certain_numeric
          memo.gsub! /[a-z]/i, ''
        end

        not_safe_for_yaml = nil
        not_safe_for_yaml ||= memo.include?('#')
        not_safe_for_yaml ||= memo =~ /\A[@,]/
        not_safe_for_yaml ||= not_numeric && memo =~ /\A[\d,]+\z/ #1,2,3, maybe a csv
        safe_for_yaml = !not_safe_for_yaml

        if safe_for_yaml
          begin
            memo = SafeYAML.load memo
          rescue Exception # Psych::SyntaxError will blow up plain rescue in 1.9.3
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
      rescue
        if options and options[:ignore_error]
          # nothing to see here
        else
          raise "#{memo.inspect} => #{$!}"
        end
      end
    end
  end
end
