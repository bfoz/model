require_relative 'dsl'
require_relative 'extrusion/builder'

class Model
    class Builder
	attr_reader :model

	include Model::DSL

	def initialize(model=nil)
	    @attribute_defaults = {}
	    @attribute_getters = {}
	    @attribute_setters = {}
	    @model = model || Model.new
	end

	# Evalute the given block in the {Model} context
	# @return [Model]   The built {Model}
	def evaluate(&block)
	    instance_eval &block if block_given?
	    @model
	end

	def define_attribute_reader(name, value=nil, &block)
	    klass = @model.respond_to?(:define_method, true) ? @model : @model.class
	    if value || block_given?
		@attribute_defaults[name] = value || block
		@model.instance_variable_set('@' + name.to_s, value || instance_eval(&block))
	    end
	    klass.send :define_method, name do
		instance_variable_get('@' + name.to_s)
	    end
	    @attribute_getters[name] = klass.instance_method(name)
	end

	def define_attribute_writer(name)
	    klass = @model.respond_to?(:define_method, true) ? @model : @model.class
	    method_name = name.to_s + '='
	    klass.send :define_method, method_name do |value|
		instance_variable_set '@' + name.to_s, value
	    end
	    @attribute_setters[method_name] = klass.instance_method(method_name)
	end

	# Define a named parameter
	# @param [Symbol] name	The name of the parameter
	# @param [Proc] block	A block that evaluates to the value of the parameter
	def let name, &block
	    @model.class.define_parameter name, &block
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

	# !@attribute [r] first
	#   @return [Element] The first element
	def first
	    elements.first
	end

	# Adds all of the given elements to the {Model}
	# @param [Array]    args The elements to add to the {Model}
	# @return   The last element added to the {Model}
	def push(*args)
	    @model.push(*args)
	end

	# Create a {Group} with an optional name and transformation
	def group(*args, &block)
	    push Model::Builder.new(Group.new(*args)).evaluate(&block)
	end

	# Create and add an {Extrusion} object with the given length and {Sketch}
	# Optionally accepts the same options as {Geometry::Transformation Transformation}
	# @param [Numeric]  length	The length of the {Extrusion}
	# @param [Sketch]   sketch	The {Sketch} to extrude
	# @param [Proc]	    block	A block to use for creating, or modifying, the {Sketch} to extrude
	# @param [Hash]	    options	Any of the options accepted by {Geometry::Transformation}
	# @return [Extrusion]   A new {Extrusion}
	def extrude(options={}, &block)
	    raise ArgumentError, "Arguments must be named" unless options.is_a?(Hash)
	    raise ArgumentError, "Can't extrude without a length" unless options[:length]
	    raise ArgumentError, "Can't extrude without a block or a sketch" unless block_given? or options[:sketch]

	    length = options.delete(:length)
	    sketch = options.delete(:sketch) { Sketch.new }
	    sketch = sketch.new unless sketch.is_a? Sketch

	    extrusion = Extrusion.new(length: length, sketch:sketch, transformation:Geometry::Transformation.new(options))
	    if block_given?
		push Model::Extrusion::Builder.new(extrusion, self).evaluate(&block)
	    else
		push extrusion
	    end
	end

	# @group Ignorance is Bliss

	# Common catcher for methods that are being ignored
	def ignore(*args, &block)
	end

	# Shortcuts for preventing elements from generating geometry
	alias :xgroup	:ignore
	alias :xextrude	:ignore

	# @endgroup
    end
end
