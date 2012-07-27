class Model
    class Builder
	attr_reader :model

	def initialize(model=nil)
	    @model = model || Model.new
	end

	# Evalute the given block in the {Model} context
	# @return [Model]   The built {Model}
	def evaluate(&block)
	    instance_eval &block if block_given?
	    @model
	end

	# Adds all of the given elements to the {Model}
	# @param [Array]    args The elements to add to the {Model}
	# @return   The last element added to the {Model}
	def push(*args)
	    @model.push(*args)
	end

	def group(*args, &block)
	    @model.push Model::Builder.new(Group.new(*args)).evaluate(&block)
	end

	# Create and add an {Extrusion} object with the given length and {Sketch}
	# Optionally accepts the same options as {Geometry::Transformation Transformation}
	# @overload extrude(length, sketch=nil, options={})
	# @param [Numeric]	length	The length of the {Extrusion}
	# @param [Sketch]	sketch	The {Sketch} to extrude
	# @param [Block]	block	A block to use for creating, or modifying, the {Sketch} to extrude
	# @return [Extrusion]   A new {Extrusion}
	def extrude(length, *args, &block)
	    options, args = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)

	    sketch = args.shift || Sketch.new
	    sketch = sketch.new unless sketch.is_a? Sketch
	    if block_given?
		builder = Sketch::Builder.new(sketch, &block) if block_given?
		sketch = builder.sketch
	    end

	    @model.add_extrusion Extrusion.new(length, sketch, options)
	end
	
	# !@group Ignorance is Bliss

	# Common catcher for methods that are being ignored
	def ignore(*args, &block)
	end
	
	# Shortcuts for preventing elements from generating geometry
	alias :xgroup	:ignore
	alias :xextrude	:ignore
	
	# !@endgroup
    end
end
