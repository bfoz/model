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

	# Define an attribute with the given name and optional default value (or block)
	# @param name [String]	The attribute's name
	# @param value An optional default value
	def define_attribute_reader(name, value=nil, &block)
	    klass = @model.respond_to?(:define_method, true) ? @model : @model.class
	    name, value = name.flatten if name.is_a?(Hash)
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
# @endgroup
    end
end
