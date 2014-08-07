require 'minitest/autorun'
require 'model/extrusion/builder'

describe Model::Extrusion::Builder do
    let(:builder) { Model::Extrusion::Builder.new }

    describe "when evaluating a block" do
	describe "with simple geometry" do
	    before do
		builder.evaluate do
		    circle [1,2], 5
		end
	    end

	    it "should create the commanded elements" do
		builder.extrusion.sketch.elements.last.must_be_kind_of Geometry::Circle
	    end
	end
    end
end
