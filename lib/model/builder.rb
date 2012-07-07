class Model
    class Builder
	attr_reader :model

	def initialize(model=nil)
	    @model = model || Model.new
	end

	def evaluate(&block)
	    instance_eval &block
	end

	# Create and add an {Extrusion} object with the given length and {Sketch}
	# @param [Numeric]	length	The length of the {Extrusion}
	# @param [Sketch]	sketch	The {Sketch} to extrude
	# @param [Block]	block	A block to use for creating, or modifying, the {Sketch} to extrude
	# @return [Extrusion]   A new {Extrusion}
	def extrude(length, sketch=nil, &block)
	    sketch = Sketch.new unless sketch
	    sketch.instance_eval(&block) if block_given?
	    @model.add_extrusion Extrusion.new(length, sketch)
	end
    end
end
