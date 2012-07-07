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
end
