require 'minitest/autorun'
require 'model'

describe Model do
    subject { Model.new }

    describe "when the constructor is passed a block" do
	before do
	    @model = Model.new do
		sketch = Sketch.new
		push Model::Extrusion.new(length:5, sketch:sketch)
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
	    model.push Model::Extrusion.new(length:5, sketch:Sketch.new)
	    model.elements.last.must_be_kind_of Model::Extrusion
	end
    end

    describe "parameters" do
	it "must define custom parameters" do
	    Model.define_parameter(:a_parameter) { 42 }
	    Model.new.a_parameter.must_equal 42
	end

	it "must bequeath custom parameters to subclasses" do
	    Model.define_parameter(:a_parameter) { 42 }
	    Class.new(Model).new.must_respond_to(:a_parameter)
	end

	it "must not allow access to parameters defined on a subclass" do
	    Model.define_parameter(:a_parameter) { 42 }
	    Class.new(Model).define_parameter(:b_parameter) { 24 }
	    Model.new.wont_respond_to :b_parameter
	end
    end

    describe "geometry" do
	before do
	    @model = Model.new
	end

	it "should be able to add an extrusion" do
	    sketch = Sketch.new
	    extrusion = @model.push(Model::Extrusion.new(length:5, sketch:sketch))
	    @model.elements.must_include extrusion
	end

	it "must push a new instance of a class" do
	    subject.push Model::Extrusion, length:5, sketch:Sketch.new, :origin => [1,2,3]
	    subject.elements.size.must_equal 1
	    subject.elements.first.must_be_instance_of(Model::Extrusion)
	    subject.elements.first.transformation.translation.must_equal Vector[1,2,3]
	end

	it "must push a Model instance with parameters" do
	    subject.push Model::Extrusion.new(length:5, sketch:Sketch.new), :origin => [1,2,3]
	    subject.elements.size.must_equal 1
	    subject.elements.first.must_be_instance_of(Model::Extrusion)
	    subject.elements.first.transformation.translation.must_equal Vector[1,2,3]
	end

	it "must push a Model instance without parameters" do
	    subject.push Model::Extrusion.new(length:5, sketch:Sketch.new)
	    subject.elements.size.must_equal 1
	    subject.elements.first.must_be_instance_of(Model::Extrusion)
	end
    end
end
