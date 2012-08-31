require 'sketch'

class Model
=begin
    An extrusion is a 2D sketch embiggened into the third dimension.
=end
    class Extrusion
	attr_accessor :length, :sketch, :transformation

	# @param [Number]   length  The distance to extrude the sketch
	# @param [Sketch]   sketch  The sketch to extrude
	# @param [Transformation]   transformation  A transformation that locates the {Extrusion} in its parent's coordinate system
	def initialize(length=nil, sketch=nil, transformation=nil)
	    if sketch
		raise ArgumentError, "sketch must be a Sketch" unless sketch.is_a?(Sketch)
		@sketch = sketch
	    end
	    @length = length if length

	    self.transformation = transformation || Geometry::Transformation.new(:dimensions => 3)
	end

	# Define an instance parameter
	# @param [Symbol] name	The name of the parameter
	# @param [Proc] block	A block that evaluates to the desired value of the parameter
	def define_parameter name, &block
	    singleton_class.send :define_method, name do
		@parameters ||= {}
		@parameters.fetch(name) { |k| @parameters[k] = instance_eval(&block) }
	    end
	end

	def transformation=(transformation)
	    @transformation = transformation
	    if @transformation
		raise ArgumentError, "#{@transformation} must be a Transformation" unless @transformation.is_a?(Geometry::Transformation)
		raise ArgumentError, "The transformation must have at least 3 dimensions" if @transformation.dimensions && (@transformation.dimensions < 3)
	    end
	end
    end
end
