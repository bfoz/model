require 'minitest/autorun'
require 'model/extrusion'

describe Model::Extrusion do
    before do
    	@extrusion = Model::Extrusion.new Sketch.new, 5
    end

    it "should have a sketch" do
	@extrusion.sketch.wont_be_nil
    end

    it "should have a length" do
	@extrusion.length.must_equal 5
    end
end
