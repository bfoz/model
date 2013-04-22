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
	    super &block

	    options, args = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)

	    @transformation = options.delete(:transformation) || Geometry::Transformation.new(options)
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
