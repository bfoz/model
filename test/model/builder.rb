require 'minitest/autorun'
require 'geometry'
require 'model/builder'

LENGTH = 3

describe Model::Builder do
    Point = Geometry::Point

    let(:builder) { Model::Builder.new }
    subject { Model::Builder.new }

    it "should create a new Model when initialized without a Model" do
	Model::Builder.new.model.must_be_instance_of(Model)
    end

    it "should use the given model when initialized with an existing Module" do
	model = Model.new
	Model::Builder.new(model).model.must_be_same_as(model)
    end

    it "must have a push method that pushes elements" do
	builder.push Model::Extrusion.new(length:5, sketch:Sketch.new)
	builder.model.elements.last.must_be_kind_of Model::Extrusion
    end

    describe 'when defining an attribute' do
	let(:model) { builder.evaluate { attribute :attribute0 } }

	it 'must define the attribute' do
	    model.must_be :respond_to?, :attribute0
	    model.must_be :respond_to?, :attribute0=
	end

	it 'must have working accessors' do
	    model.attribute0 = 42
	    model.attribute0.must_equal 42
	end

	it 'must make the attribute available while evaluating a block' do
	    builder.evaluate do
		attribute :attribute1, 5
		attribute1.must_equal 5
		attribute1 = 7
		attribute1.must_equal 7
	    end
	end
    end

    describe 'when defining an attribute with a default value' do
	let(:model) { builder.evaluate { attribute :attribute0, 42 } }

	it 'must have the default value' do
	    model.attribute0.must_equal 42
	end

	it 'must not have the default value after setting to nil' do
	    model.attribute0 = nil
	    model.attribute0.wont_equal 42
	end
    end

    describe 'when defining a read only attribute with a default value' do
	let(:model) { builder.evaluate { attr_reader attribute0:42 } }

	it 'must have the default value' do
	    model.attribute0.must_equal 42
	end

	it 'must not have the default value after setting to nil' do
	    model.attribute0 = nil
	    model.attribute0.wont_equal 42
	end
    end

    describe "when evaluating a block" do
	describe "with simple geometry" do
	    before do
		builder.evaluate do
		    extrude length:5, sketch:Sketch.new
		end
	    end

	    it "should create the commanded elements" do
		builder.model.elements.last.must_be_instance_of Model::Extrusion
	    end

	    it 'must have an accessor for the first element' do
		builder.first.must_be_instance_of Model::Extrusion
	    end

	    it 'must have an accessor for the last element' do
		builder.last.must_be_instance_of Model::Extrusion
	    end
	end

	describe "with a parameter" do
	    before do
		builder.evaluate do
		    let(:parameterA) { 42 }
		    extrude length: parameterA, sketch: Sketch.new
		end
	    end

	    it "must define the parameter" do
		builder.model.parameterA.must_equal 42
	    end

	    it "must use the parameter" do
		builder.model.elements.last.must_be_instance_of Model::Extrusion
		builder.model.elements.last.length.must_equal 42
	    end
	end

	describe "with a group" do
	    describe "with a group" do
		before do
		    subject.evaluate do
			group do
			    group origin: [1,2,3] do
				extrude length:LENGTH, sketch:Sketch.new, origin: [3,4,5]
			    end
			end
		    end
		end

		it "should have only one element at the top level" do
		    subject.model.elements.count.must_equal 1
		end

		it "should create the commanded elements" do
		    outer_group = subject.model.elements.last
		    outer_group.must_be_instance_of Model::Group

		    inner_group = outer_group.elements.last
		    inner_group.must_be_instance_of Model::Group
		    inner_group.translation.must_equal Point[1,2,3]

		    extrusion = inner_group.elements.last
		    extrusion.must_be_instance_of Model::Extrusion
		    extrusion.length.must_equal LENGTH
		    extrusion.transformation.translation.must_equal Point[3,4,5]
		end
	    end
	end
    end

    describe "when evaluating a block within a block" do
	before do
	    skip
	    builder.evaluate do
		group do
		    extrude length:LENGTH, sketch:Sketch.new
		end
	    end
	end

	it "should create the commanded elements" do
	    builder.model.elements.last.must_be_instance_of Model::Group
	end

	it "must be able to access global constants" do
	    builder.model.elements.last.elements.last.length.must_equal LENGTH
	end
    end

    describe "when adding an Extrusion" do
	describe "without a length parameter" do
	    it "must raise an exception" do
		-> { subject.extrude }.must_raise ArgumentError
	    end
	end

	describe 'without a block or a sketch' do
	    it 'must raise an exception' do
		-> { subject.extrude length:10 }.must_raise ArgumentError
	    end
	end

	describe "with a length and a Sketch" do
	    describe "when the sketch parameter is an instance of a Sketch" do
		before do
		    builder.extrude length:10, sketch:Sketch.new do
			rectangle size:[5, 6]
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

	    describe "when the sketch parameter is a class derived from Sketch" do
		before do
		    builder.extrude length:10, sketch:Sketch do
			rectangle size:[5, 6]
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

	end

	describe "with a length and a block" do
	    before do
		builder.extrude length:11 do
		    rectangle size:[5, 6]
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
	    describe "when given an origin" do
		before do
		    builder.extrude length:11, :origin => Point[4,2,0] do
			rectangle size:[5, 6]
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
		    extrusion.transformation.translation.must_equal Point[4,2,0]
		end
	    end

	    describe "when given a zero origin" do
		before do
		    builder.extrude length:10, :origin => [0,0,0] do
			rectangle size:[5, 6]
		    end
		end

		it "should have an Extrusion element" do
		    extrusion = builder.model.elements.last
		    extrusion.must_be_instance_of Model::Extrusion
		end
	    end

	    describe "when given axes and no origin" do
		before do
		    builder.extrude length:3, :x => [0,1,0], :y => [0,0,1] do
			rectangle size:[1,2]
		    end
		end

		it "should have an Extrusion element" do
		    extrusion = builder.model.elements.last
		    extrusion.must_be_instance_of Model::Extrusion
		end

		it "must transform the extrusion element" do
		    extrusion = builder.model.elements.last
		    transformation = extrusion.transformation
		    transformation.identity?.wont_equal(true)
		    extrusion.transformation.translation.must_equal nil
		    extrusion.transformation.rotation.x.must_equal [0,1,0]
		    extrusion.transformation.rotation.y.must_equal [0,0,1]
		end
	    end
	end
    end

    describe "when adding a group" do
	describe "without a block" do
	    before do
		builder.group :origin => [1,2,3]
	    end

	    it "must have a group element" do
		builder.model.elements.first.must_be_kind_of Model::Group
		builder.model.elements.first.translation.must_equal Point[1,2,3]
	    end
	end

	describe "with a block" do
	    before do
		subject.group :origin => [1,2,3] do
		    extrude length:LENGTH, sketch:Sketch.new
		end
	    end

	    it "must have a group element" do
		subject.model.elements.first.must_be_kind_of Model::Group
	    end

	    it "must have the correct property values" do
		subject.model.elements.first.translation.must_equal Point[1,2,3]
	    end
	end
    end

    describe "when adding a translation group" do
	describe "without a block" do
	    before do
		subject.translate [1,2,3]
	    end

	    it "must have a group element" do
		subject.elements.first.must_be_kind_of Model::Group
	    end

	    it "must set the group origin" do
		subject.elements.first.translation.must_equal Point[1,2,3]
	    end
	end

	describe "with a block" do
	    before do
		subject.translate [1,2,3] { extrude length:LENGTH, sketch:Sketch.new }
	    end

	    it "must have a group element" do
		subject.elements.first.must_be_kind_of Model::Group
	    end

	    it "must set the group origin" do
		subject.elements.first.translation.must_equal Point[1,2,3]
	    end
	end

	describe "with a nested translation group" do
	    before do
		subject.translate [1,2,3] do
		    translate [4,5,6] { extrude length:LENGTH, sketch:Sketch.new }
		end
	    end

	    it "must have a group element" do
		subject.first.must_be_kind_of Model::Group
	    end

	    it "must set the group origin" do
		subject.first.translation.must_equal Point[1,2,3]
	    end

	    describe "subgroup" do
		let(:subgroup) { subject.first.first }

		it "must have a sub-group element" do
		    subgroup.must_be_kind_of Model::Group
		end

		it "must set the group origin" do
		    subgroup.translation.must_equal Point[4,5,6]
		end
	    end
	end

    end

    describe "when ignorance is bliss" do
	it "must ignore xextrude" do
	    builder.xextrude
	    builder.model.elements.count.must_equal 0
	end

	it "must ignore xgroup" do
	    builder.xgroup
	    builder.model.elements.count.must_equal 0
	end

	it 'must ignore xtranslate' do
	    builder.xtranslate
	    builder.model.elements.count.must_equal 0
	end
    end
end
