require 'minitest/autorun'
require 'model'

describe Model do
    describe "when the constructor is passed a block" do
	before do
	    @model = Model.new do
		sketch = Sketch.new
		add_extrusion(Model::Extrusion.new(5, sketch))
	    end
	end

	it "should create a new Model and use it to evaluate the block" do
	    @model.must_be_instance_of(Model)
	    @model.elements.last.must_be_instance_of Model::Extrusion
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

    describe "properties and methods" do
	let(:model) { Model.new }

	it "should have an elements accessor" do
	    model.must_respond_to :elements
	end

	it "should have an empty? property" do
	    model.must_respond_to :empty?
	end

	it "must have a push method that pushes elements" do
	    model.push Model::Extrusion.new(5, Sketch.new)
	    model.elements.last.must_be_kind_of Model::Extrusion
	end
    end

    describe "geometry" do
	before do
	    @model = Model.new
	end

	it "should be able to add an extrusion" do
	    sketch = Sketch.new
	    extrusion = @model.add_extrusion(Model::Extrusion.new(5, sketch))
	    @model.elements.must_include extrusion
	end
    end
end
