require 'spec_helper'

describe Parse do
  it "should parse with version 0.0.2 of the algorithm" do
    v = "  1990-04-03  "
    expect(Parse.parse(v)).to eq(Parse.ver0_0_2(v))
  end
end
