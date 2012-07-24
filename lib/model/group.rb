require 'geometry/transformation'

=begin
{Group} is a container for grouping elements of a {Model} with an optional
{Geometry::Transformation Transformation} property.

    model :ExampleModel do
        group origin => Point[4,2] do
            square 5.meters
        end
    end
=end
class Model
    class Group < Model
	attr_reader :transformation

	def initialize(*args, &block)
	    @transformation = Geometry::Transformation.new(*args)
	    super &block
	end

	def rotation
	    @transformation.rotation
	end

	def scale
	    @transformation.scale
	end

	def translation
	    @transformation.translation
	end
    end
end
