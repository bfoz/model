class Model
    # Syntactic sugar for building a {Model} object
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
	    define_attribute_reader(name, &block)
	end

	# Define a new write-only {Model} attribute
	# @param name [String,Symbol]	The new attribute's name
	def attr_writer(name)
	    define_attribute_writer(name)
	end

	# @overload translate(origin, block)
	#   Create a {Group} using the given translation
	# @param [Point] origin	The distance by which to translate the enclosed geometry
	def translate(*args, &block)
	    group(origin:Point[*args], &block)
	end
    end
end
