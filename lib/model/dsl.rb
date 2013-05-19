class Model
    # Syntactic sugar for building a {Model} object
    module DSL
	# @overload translate(origin, block)
	#   Create a {Group} using the given translation
	# @param [Point] origin	The distance by which to translate the enclosed geometry
	def translate(*args, &block)
	    group(origin:Point[*args], &block)
	end
    end
end
