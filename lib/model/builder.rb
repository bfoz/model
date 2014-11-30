require_relative 'dsl'
require_relative 'extrusion/builder'
require_relative 'layout'

class Model
    class Builder
	attr_reader :model

	include Model::DSL

	def initialize(model=nil)
	    @model = model || Model.new
	end

	# Evaluate the given block in the {Model} context
	# @return [Model]   The built {Model}
	def evaluate(&block)
	    instance_eval &block if block_given?
	    @model
	end

	# Try to redirect missing methods to the {Model} or fall thru to super
	def method_missing(id, *args, &block)
	    if @model.respond_to?(id)
		@model.send id, *args, &block
	    else
		super if defined?(super)
	    end
	end

	# !@attribute [r] elements
	#   @return [Array] The current list of elements
	def elements
	    @model.elements
	end

# @group DSL support methods

private
	# Adds all of the given elements to the {Model}
	# @param [Array]    args The elements to add to the {Model}
	# @return   The last element added to the {Model}
	def push(*args)
	    elements.push(*args)
	end

	# Build a new {Extrusion}
	# @param length [Number]    the length of the extrusion
	# @param sketch [Sketch]    a {Sketch} to extrude (or nil)
	# @param parent	[Object]    a parent context to use while building
	# @param options [Hash]	    anything that needs to be passed to the new {Extrusion} instance
	def build_extrusion(length, sketch, parent, options={}, &block)
	    sketch ||= Sketch.new
	    sketch = sketch.new unless sketch.is_a? Sketch
	    extrusion = Extrusion.new(length: length, sketch:sketch, transformation:Geometry::Transformation.new(options))
	    if block_given?
		Model::Extrusion::Builder.new(extrusion, parent).evaluate(&block)
	    else
		extrusion
	    end
	end

	# Build a new {Group}
	def build_group(*args, &block)
	    Model::Builder.new(Group.new(*args)).evaluate(&block)
	end

	# Build a new {Layout}
	def build_layout(*args, **options, &block)
	    Model::Builder.new(Layout.new(*args, **options)).evaluate(&block)
	end
# @endgroup
    end
end
