require 'minitest/autorun'
require 'geometry'
require 'model/builder'

describe Model::Builder do
    Point = Geometry::Point

    let(:builder) { Model::Builder.new }

    it "should create a new Model when initialized without a Model" do
	Model::Builder.new.model.must_be_instance_of(Model)
    end

    it "should use the given model when initialized with an existing Module" do
	model = Model.new
	Model::Builder.new(model).model.must_be_same_as(model)
    end

    it "must have a push method that pushes elements" do
	builder.push Model::Extrusion.new(5, Sketch.new)
	builder.model.elements.last.must_be_kind_of Model::Extrusion
    end

    describe "when evaluating a block" do
	before do
	    builder.evaluate do
		extrude 5, Sketch.new
	    end
	end

	it "should create the commanded elements" do
	    builder.model.elements.last.must_be_instance_of Model::Extrusion
	end
    end

    describe "when adding an Extrusion" do
	describe " with a length and a Sketch" do
	    before do
		builder.extrude 10, Sketch.new do
		    rectangle 5, 6
		end
		builder.model.elements.last.must_be_instance_of Model::Extrusion
	    end

	    it "should have an Extrusion element" do
		builder.model.elements.last.must_be_instance_of Model::Extrusion
		builder.model.elements.last.length.must_equal 10
	    end

	    it "should make a Rectangle in the Extrusion's Sketch" do
		extrusion = builder.model.elements.last
		sketch = extrusion.sketch
		sketch.elements.last.must_be_kind_of Geometry::Rectangle
	    end
	end

	describe "with a length and a block" do
	    before do
		builder.extrude 11 do
		    rectangle 5, 6
		end
	    end

	    it "should have an Extrusion element" do
		builder.model.elements.last.must_be_instance_of Model::Extrusion
	    end

	    it "should make a Rectangle in the Extrusion's Sketch" do
		extrusion = builder.model.elements.last
		sketch = extrusion.sketch
		sketch.elements.last.must_be_kind_of Geometry::Rectangle
	    end
	end

	describe "with transformation options" do
	    before do
		builder.extrude 11, :origin => Point[4,2] do
		    rectangle 5, 6
		end
	    end

	    it "should have an Extrusion element" do
		builder.model.elements.last.must_be_instance_of Model::Extrusion
	    end

	    it "should make a Rectangle in the Extrusion's Sketch" do
		extrusion = builder.model.elements.last
		sketch = extrusion.sketch
		sketch.elements.last.must_be_kind_of Geometry::Rectangle
	    end

	    it "must have a transformation" do
		extrusion = builder.model.elements.last
		extrusion.transformation.must_be_instance_of(Geometry::Transformation)
		extrusion.transformation.translation.must_equal Point[4,2]
	    end

	end

	end
    end

end
