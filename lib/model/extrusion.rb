require 'sketch'

class Model
=begin
    An extrusion is a 2D sketch embiggened into the third dimension.
=end
    class Extrusion
	attr_accessor :length, :sketch
	attr_reader :transformation

	# @param [Number]   length  The distance to extrude the sketch
	# @param [Sketch]   sketch  The sketch to extrude
	# @param [Transformation]   transformation  A transformation that locates the {Extrusion} in its parent's coordinate system
	def initialize(length, sketch, *args)
	    options, args = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)
	    transformation = args.shift

	    raise ArgumentError, "sketch must be a Sketch" unless sketch && sketch.is_a?(Sketch)
	    @length = length
	    @sketch = sketch

	    options[:dimensions] = 3 unless options.key?(:dimensions) && (options[:dimensions] >= 3)
	    @transformation = transformation || Geometry::Transformation.new(options)
	    raise ArgumentError, "#{@transformation} must be a Transformation" if @transformation && !@transformation.is_a?(Geometry::Transformation)
	    raise ArgumentError, "The transformation must have at least 3 dimensions" if @transformation.dimensions < 3
	end
    end
end
