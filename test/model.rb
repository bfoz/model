require 'minitest/autorun'
require 'model'

describe Model do
    describe "when the constructor is passed a block" do
	before do
	    @model = Model.new do
	    end
	end

	it "should create a new Model and use it to evaluate the block" do
	    @model.must_be_instance_of(Model)
	end
    end

    describe "when the constructor is not passed a block" do
	before do
	    @model = Model.new
	end

	it "should create a new empty Model" do
	    @model.must_be_instance_of(Model)
	    @model.must_be_empty
	end
    end

    describe "properties" do
	before do
	    @model = Model.new
	end

	it "should have an elements accessor" do
	    @model.must_respond_to :elements
	end

	it "should have an empty? property" do
	    @model.must_respond_to :empty?
	end
    end

    describe "geometry" do
	before do
	    @model = Model.new
	end

	it "should extrude a sketch object" do
	    sketch = Sketch.new
	    extrusion = @model.add_extrusion(5, sketch)
	    @model.elements.must_include extrusion
	end
    end
end
