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

	describe "that defines a parameter" do
	    before do
		builder.evaluate do
		    let(:parameterA) { 42 }
		    circle [1,2], parameterA
		end
	    end

	    it "must define the parameter" do
		builder.extrusion.parameterA.must_equal 42
	    end

	    it "must use the parameter" do
		builder.extrusion.sketch.elements.last.must_be_instance_of Geometry::Circle
		builder.extrusion.sketch.elements.last.radius.must_equal 42
	    end
	end

	describe "that uses a parameter defined in a parent model" do
	    let(:parameter_value) do
		temp = nil
		Model::Builder.new.evaluate do
		    let(:parameterA) { 42 }
		    extrude length:5 do
			temp = parameterA
		    end
		end
		temp
	    end

	    it "must use the parent's value of the parameter" do
		parameter_value.must_equal 42
	    end
	end

	describe "that redefines a parameter from the parent model" do
	    let(:parameter_value) do
		temp = nil
		Model::Builder.new.evaluate do
		    let(:parameterA) { 42 }
		    extrude length:5 do
			let(:parameterA) { 3 }
			temp = parameterA
		    end
		end
		temp
	    end

	    it "must use the redefined value of the parameter" do
		parameter_value.must_equal 3
	    end
	end
    end
end
