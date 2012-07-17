require 'minitest/autorun'
require 'model/extrusion'

describe Model::Extrusion do
    Extrusion = Model::Extrusion

    before do
    	@extrusion = Model::Extrusion.new 5, Sketch.new
    end

    it "should have a sketch" do
	@extrusion.sketch.wont_be_nil
    end

    it "should have a length" do
	@extrusion.length.must_equal 5
    end

    it "must raise an exception when constructed with something that isn't a Sketch" do
	lambda { Extrusion.new 5, 5 }.must_raise ArgumentError
    end

    describe "when constructed" do
	it "must accept a transformation argument" do
	    e = Extrusion.new(5, Sketch.new, :transformation => Geometry::Transformation.new)
	    e.must_be_instance_of(Extrusion)
	    e.transformation.must_be_instance_of(Geometry::Transformation)
	end

	it "must raise an exception if transformation isn't a Transformation" do
	    lambda { Extrusion.new 5, 5, Array.new }.must_raise ArgumentError
	    lambda { Extrusion.new :transformation => Array.new }.must_raise ArgumentError
	end

    end

end
