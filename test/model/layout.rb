require 'minitest/autorun'
require 'model/layout'

describe Model::Layout do
    Group = Model::Group
    Point = Geometry::Point

    describe 'when constructed' do
	describe 'with no arguments' do
	    subject { Model::Layout.new }

	    it 'must have an identity transformation' do
		subject.transformation.identity?.must_equal true
	    end

	    it 'must be empty' do
		subject.elements.size.must_equal 0
	    end
	end

	describe 'with a transformation' do
	    subject { Model::Layout.new origin:[1,2,3] }

	    it 'must set the transformation property' do
		subject.transformation.must_equal Geometry::Transformation.new(origin:Point[1,2,3])
	    end
	end
    end

    describe 'when horizontal' do
	subject { Model::Layout.new :horizontal }
	let(:sketch) { Sketch.new.tap(){|sketch| sketch.push Geometry::Rectangle.new(center:[0,0], size:[10,10])} }

	it 'must layout horizontally' do
	    subject.push(Extrusion.new(length:5, sketch:sketch))
	    subject.push(Extrusion.new(length:5, sketch:sketch))

	    subject.first.transformation.translation.must_equal Point[5.0, 0, 0]
	    subject.last.transformation.translation.must_equal Point[15.0,0,0]
	end

	it 'must layout groups' do
	    subject.push(Group.new.tap do |group|
		group.push Extrusion.new(length:5, sketch:sketch)
	    end)

	    subject.push(Group.new.tap do |group|
		group.push Extrusion.new(length:5, sketch:sketch)
	    end)

	    subject.first.transformation.translation.must_equal Point[5.0, 0, 0]
	    subject.last.transformation.translation.must_equal Point[15.0,0,0]
	end

	describe 'with spacing' do
	    subject { Model::Layout.new :horizontal, spacing:1 }

	    it 'must add space between the elements' do
		subject.push(Extrusion.new(length:5, sketch:sketch))
		subject.push(Extrusion.new(length:5, sketch:sketch))

		subject.first.transformation.translation.must_equal Point[5.0, 0, 0]
		subject.last.transformation.translation.must_equal Point[16.0,0, 0]
	    end
	end

	describe 'when bottom aligned' do
	    subject { Model::Layout.new :horizontal, :bottom }

	    it 'must bottom align the elements' do
		subject.push(Extrusion.new(length:4, sketch:sketch))
		subject.push(Extrusion.new(length:5, sketch:sketch))

		subject.first.transformation.translation.must_equal Point[5.0, 0, 0]
		subject.last.transformation.translation.must_equal Point[15.0, 0, 0]
	    end
	end

	describe 'when top aligned' do
	    subject { Model::Layout.new :horizontal, :top }

	    it 'must top align the elements' do
		subject.push(Extrusion.new(length:4, sketch:sketch))
		subject.push(Extrusion.new(length:5, sketch:sketch))

		subject.first.transformation.translation.must_equal Point[5.0, 0, -4]
		subject.last.transformation.translation.must_equal Point[15.0, 0, -5]
	    end
	end
    end

    describe 'when lateral' do
	subject { Model::Layout.new :lateral }
	let(:sketch) { Sketch.new.tap(){|sketch| sketch.push Geometry::Rectangle.new(center:[0,0], size:[10,10])} }

	it 'must layout laterally' do
	    subject.push(Extrusion.new(length:5, sketch:sketch))
	    subject.push(Extrusion.new(length:5, sketch:sketch))

	    subject.first.transformation.translation.must_equal Point[0, 5.0, 0]
	    subject.last.transformation.translation.must_equal Point[0, 15.0, 0]
	end

	it 'must layout groups' do
	    subject.push(Group.new.tap do |group|
		group.push Extrusion.new(length:5, sketch:sketch)
	    end)

	     subject.push(Group.new.tap do |group|
		group.push Extrusion.new(length:5, sketch:sketch)
	    end)

	  subject.first.transformation.translation.must_equal Point[0, 5.0, 0]
	  subject.last.transformation.translation.must_equal Point[0, 15.0, 0]
	end

	describe 'with spacing' do
	    subject { Model::Layout.new :lateral, spacing:1 }

	    it 'must add space between the elements' do
		subject.push(Extrusion.new(length:5, sketch:sketch))
		subject.push(Extrusion.new(length:5, sketch:sketch))

		subject.first.transformation.translation.must_equal Point[0, 5.0, 0]
		subject.last.transformation.translation.must_equal Point[0, 16.0, 0]
	    end
	end

	describe 'when bottom aligned' do
	    subject { Model::Layout.new :lateral, :bottom }

	    it 'must bottom align the elements' do
		subject.push(Extrusion.new(length:4, sketch:sketch))
		subject.push(Extrusion.new(length:5, sketch:sketch))

		subject.first.transformation.translation.must_equal Point[0, 5.0, 0]
		subject.last.transformation.translation.must_equal Point[0, 15.0, 0]
	    end
	end

	describe 'when top aligned' do
	    subject { Model::Layout.new :lateral, :top }

	    it 'must top align the elements' do
		subject.push(Extrusion.new(length:4, sketch:sketch))
		subject.push(Extrusion.new(length:5, sketch:sketch))

		subject.first.transformation.translation.must_equal Point[0, 5.0, -4]
		subject.last.transformation.translation.must_equal Point[0, 15.0, -5]
	    end
	end

	describe 'when left aligned' do
	    let(:layout) { Model::Layout.new :lateral, :left }
	    let(:sketch_small) { Sketch.new.tap(){|sketch| sketch.push Geometry::Rectangle.new(center:[0,0], size:[8,8])} }

	    it 'must left align the elements' do
		layout.push(Extrusion.new(length:5, sketch:sketch_small))
		layout.push(Extrusion.new(length:5, sketch:sketch))

		layout.first.transformation.translation.must_equal Point[4.0,4.0,0]
		layout.last.transformation.translation.must_equal Point[5.0,13.0,0]
	    end
	end

	describe 'when right aligned' do
	    let(:layout) { Model::Layout.new :lateral, :right }
	    let(:sketch_small) { Sketch.new.tap(){|sketch| sketch.push Geometry::Rectangle.new(center:[0,0], size:[8,8])} }

	    it 'must right align the elements' do
		layout.push(Extrusion.new(length:5, sketch:sketch_small))
		layout.push(Extrusion.new(length:5, sketch:sketch))

		layout.elements.length.must_equal 2

		layout.first.transformation.translation.must_equal Point[-4.0,4.0,0]
		layout.last.transformation.translation.must_equal Point[-5.0,13.0,0]
	    end
	end
    end

    describe 'when vertical' do
	subject { Model::Layout.new :vertical }
	let(:sketch) { Sketch.new.tap(){|sketch| sketch.push Geometry::Rectangle.new(center:[0,0], size:[10,10])} }

	it 'must layout vertically' do
	    subject.push(Extrusion.new(length:5, sketch:sketch))
	    subject.push(Extrusion.new(length:5, sketch:sketch))

	    subject.first.transformation.translation.must_be_nil
	    subject.last.transformation.translation.must_equal Point[0,0,5]
	end

	it 'must layout groups' do
	    subject.push(Group.new.tap do |group|
		group.push Extrusion.new(length:5, sketch:sketch)
	    end)

	    subject.push(Group.new.tap do |group|
		group.push Extrusion.new(length:5, sketch:sketch)
	    end)

	    subject.first.transformation.translation.must_be_nil
	    subject.last.transformation.translation.must_equal Point[0,0,5]
	end

	describe 'with spacing' do
	    subject { Model::Layout.new :vertical, spacing:1 }

	    it 'must add space between the elements' do
		subject.push(Extrusion.new(length:5, sketch:sketch))
		subject.push(Extrusion.new(length:5, sketch:sketch))

		subject.first.transformation.translation.must_be_nil
		subject.last.transformation.translation.must_equal Point[0,0,6]
	    end
	end

	describe 'when left aligned' do
	    let(:layout) { Model::Layout.new :vertical, :left }
	    let(:sketch_small) { Sketch.new.tap(){|sketch| sketch.push Geometry::Rectangle.new(center:[0,0], size:[8,8])} }

	    it 'must left align the elements' do
		layout.push(Extrusion.new(length:5, sketch:sketch_small))
		layout.push(Extrusion.new(length:5, sketch:sketch))

		layout.first.transformation.translation.must_equal Point[4.0,0,0]
		layout.last.transformation.translation.must_equal Point[5.0,0,5]
	    end
	end

	describe 'when right aligned' do
	    let(:layout) { Model::Layout.new :vertical, :right }
	    let(:sketch_small) { Sketch.new.tap(){|sketch| sketch.push Geometry::Rectangle.new(center:[0,0], size:[8,8])} }

	    it 'must right align the elements' do
		layout.push(Extrusion.new(length:5, sketch:sketch_small))
		layout.push(Extrusion.new(length:5, sketch:sketch))

		layout.elements.length.must_equal 2

		layout.first.transformation.translation.must_equal Point[-4.0,0,0]
		layout.last.transformation.translation.must_equal Point[-5.0,0,5]
	    end
	end
    end
end
