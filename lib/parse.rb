require "parse/version"
require 'parse/algorithm'
require 'parse/algorithm/ver0_0_1'
require 'parse/algorithm/ver0_0_2'

require 'date'
require 'yaml'
require 'safe_yaml/load'
require 'active_support/core_ext'

module Parse
  def self.parse(raw, options = nil)
    ver0_0_2 raw, options
  end

  def self.ver0_0_2(*args)
    Algorithm::Ver0_0_2.new(*args).result
  end

  def self.ver0_0_1(*args)
    Algorithm::Ver0_0_1.new(*args).result
  end

end
