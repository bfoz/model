require 'minitest/autorun'
require 'model/builder'

describe Model::Builder do
    before do
    	@builder = Model::Builder.new
    end

    it "should create a new Model when initialized without a Model" do
	Model::Builder.new.model.must_be_instance_of(Model)
    end

    it "should use the given model when initialized with an existing Module" do
	model = Model.new
	Model::Builder.new(model).model.must_be_same_as(model)
    end

    describe "when evaluating a block" do
	before do
	    @builder.evaluate do
		extrude 5, Sketch.new
	    end
	end

	it "should create the commanded elements" do
	    @builder.model.elements.last.must_be_instance_of Model::Extrusion
	end
    end

    describe "when adding an Extrusion with a length and a Sketch" do
	before do
	    @builder.extrude 10, Sketch.new do
		add_rectangle 5, 6
	    end
	    @builder.model.elements.last.must_be_instance_of Model::Extrusion
	end

	it "should have an Extrusion element" do
	    @builder.model.elements.last.must_be_instance_of Model::Extrusion
	end

	it "should make a Rectangle in the Extrusion's Sketch" do
	    extrusion = @builder.model.elements.last
	    sketch = extrusion.sketch
	    sketch.elements.last.must_be_kind_of Geometry::Rectangle
	end
    end

    describe "when adding an Extrusion with a length and a block" do
	before do
	    @builder.extrude 11 do
		add_rectangle 5, 6
	    end
	end

	it "should have an Extrusion element" do
	    @builder.model.elements.last.must_be_instance_of Model::Extrusion
	end

	it "should make a Rectangle in the Extrusion's Sketch" do
	    extrusion = @builder.model.elements.last
	    sketch = extrusion.sketch
	    sketch.elements.last.must_be_kind_of Geometry::Rectangle
	end
    end

end
