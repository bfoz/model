class Model
    class Builder
	attr_reader :model

	def initialize(model=nil)
	    @model = model || Model.new
	end

	def evaluate(&block)
	    instance_eval &block
	    @model
	end

	# Create and add an {Extrusion} object with the given length and {Sketch}
	# @param [Numeric]	length	The length of the {Extrusion}
	# @param [Sketch]	sketch	The {Sketch} to extrude
	# @param [Block]	block	A block to use for creating, or modifying, the {Sketch} to extrude
	# @return [Extrusion]   A new {Extrusion}
	def extrude(length, sketch=nil, &block)
	    sketch = Sketch.new unless sketch
	    sketch = sketch.new unless sketch.is_a? Sketch
	    if block_given?
		builder = Sketch::Builder.new(sketch, &block) if block_given?
		sketch = builder.sketch
	    end
	    @model.add_extrusion Extrusion.new(length, sketch)
	end
    end
end
