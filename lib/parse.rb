require "parse/version"
require 'parse/algorithm'
require 'parse/algorithm/ver0_0_1'
require 'parse/algorithm/ver0_1_0'

require 'date'
require 'yaml'
require 'safe_yaml/load'
require 'active_support/core_ext'

module Parse
  def self.parse(raw, options = nil)
    ver0_1_0 raw, options
  end

  def self.ver0_1_0(*args)
    Algorithm::Ver0_1_0.new(*args).result
  end

  def self.ver0_0_1(*args)
    Algorithm::Ver0_0_1.new(*args).result
  end

end
