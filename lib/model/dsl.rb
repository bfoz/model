class Model
    # Syntactic sugar for building {Model} geometry
    # The including Class or Module is required to implement suitable push and elements methods.
    module DSL
	# Define a new read-write {Model} attribute. An optional default value can be supplied as either an argument, or as a block. The block will be evaluated the first time the attribute is accessed.
	# @param name [String,Symbol]	The new attribute's name
	# @param value A default value for the new attribute
	def attr_accessor(name, value=nil, &block)
	    define_attribute_reader name, value, &block
	    define_attribute_writer name
	end
	alias :attribute :attr_accessor

	# Define a new read-only {Model} attribute.  An optional default value can be supplied as either an argument, or as a block. The block will be evaluated the first time the attribute is accessed.
	# @param name [String,Symbol]	The new attribute's name
	# @param value A default value for the new attribute
	def attr_reader(name, value=nil, &block)
	    define_attribute_reader(name, value, &block)
	end

	# Define a new write-only {Model} attribute
	# @param name [String,Symbol]	The new attribute's name
	def attr_writer(name)
	    define_attribute_writer(name)
	end

	# @return [Element] The first element
	def first
	    elements.first
	end

	# @return [Element] The most recently pushed element
	def last
	    elements.last
	end

	# Create a {Group} with an optional name and transformation
	def group(*args, &block)
	    push build_group(*args, &block)
	end

	# Create a {Group} using the given translation
	# @overload translate(x, y, &block)
	#   @param x [Number]	the x-component of the desired translation
	#   @param y [Number]	the y-component of the desired translation
	#   @param z [Number]	the z-component of the desired translation
	# @overload translate(point, &block)
	#   @param point [Point]	The distance by which to translate the enclosed geometry
	# @overload translate(options, &block)
	#   @option options :x [Number]	the x-component of the desired translation
	#   @option options :y [Number]	the y-component of the desired translation
	#   @option options :z [Number]	the z-component of the desired translation
	def translate(x=nil, y=nil, z=nil, **options, &block)
	    point = Point[x || options[:x] || 0, y || options[:y] || 0, z || options[:z] || 0]
	    group(origin:point, &block)
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
	    raise ArgumentError, "Can't extrude without either a block or a sketch" unless block_given? or options[:sketch]

	    length = options.delete(:length)
	    sketch = options.delete(:sketch)

	    push build_extrusion(length, sketch, self, options, &block)
	end

	# @group Ignorance is Bliss

	# Common catcher for methods that are being ignored
	def ignore(*args, &block)
	end

	# Shortcuts for preventing elements from generating geometry
	alias :xgroup	:ignore
	alias :xextrude	:ignore
	alias :xtranslate   :ignore

	# @endgroup
    end
end
