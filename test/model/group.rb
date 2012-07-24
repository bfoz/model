require 'minitest/autorun'
require 'model/group'

describe Model::Group do
    describe "when constructed" do
	it "must accept valid Transformation arguments" do
	    group = Model::Group.new :origin => [1,2,3]
	    group.transformation.translation.must_equal Point[1,2,3]
	end

	it "must accept no arguments and like it" do
	    group = Model::Group.new
	    group.transformation.identity?.must_equal true
	end
    end
end
