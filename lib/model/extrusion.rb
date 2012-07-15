require 'sketch'

class Model
=begin
    An extrusion is a 2D sketch embiggened into the third dimension.
=end
    class Extrusion
	attr_accessor :length, :sketch

	# @param [Sketch]   sketch  The sketch to extrude
	# @param [Number]   length  The distance to extrude the sketch
	def initialize(length, sketch)
	    raise ArgumentError unless sketch
	    @length = length
	    @sketch = sketch
	end
    end
end
