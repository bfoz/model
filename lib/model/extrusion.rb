require 'sketch'

module Model
=begin
    An extrusion is a 2D sketch embiggened into the third dimension.
=end
    class Extrusion
	attr_accessor :length, :sketch

	# @param [Sketch]   sketch  The sketch to extrude
	# @param [Number]   length  The distance to extrude the sketch
	def initialize(sketch, length)
	    @sketch = sketch
	    @length = length
	end
    end
end
