require 'minitest/autorun'
require 'model/extrusion'

describe Model::Extrusion do
    Extrusion = Model::Extrusion

    subject { Model::Extrusion.new length:5, sketch:Sketch.new }

    it "should have a sketch" do
	subject.sketch.wont_be_nil
    end

    it "should have a length" do
	subject.length.must_equal 5
    end

    it "must raise an exception when constructed with something that isn't a Sketch" do
	lambda { Extrusion.new sketch:5 }.must_raise ArgumentError
    end

    describe "when constructed" do
	it "must accept a transformation argument" do
	    e = Extrusion.new(length:5, sketch:Sketch.new, transformation:Geometry::Transformation.new)
	    e.must_be_instance_of(Extrusion)
	    e.transformation.must_be_instance_of(Geometry::Transformation)
	end

	it "must raise an exception if transformation isn't a Transformation" do
	    lambda { Extrusion.new transformation:Array.new }.must_raise ArgumentError
	end
    end

    describe "properties" do
	it "must have a transformation setter" do
	    Extrusion.new.transformation = Geometry::Transformation.new
	end
    end

    describe "instance parameters" do
	let(:extrusionA) { Model::Extrusion.new }
	let(:extrusionB) { Model::Extrusion.new }

	it "must define an instance parameter" do
	    extrusionA.define_parameter(:parameterA) { 42 }
	    extrusionA.parameterA.must_equal 42
	end

	it "must not bleed parameters between instances" do
	    extrusionA.define_parameter(:parameterA) { 42 }
	    extrusionA.parameterA.must_equal 42
	    extrusionB.define_parameter(:parameterA) { 3 }
	    extrusionB.parameterA.must_equal 3
	end
    end
end
