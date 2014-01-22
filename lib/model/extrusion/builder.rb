#require 'extrusion'

class Model
    class Extrusion
	class Builder
	    attr_reader :extrusion

	    # @param [Extrusion]    An extrusion to work with
	    # @param [Model]	    A parent {Model} to use for parameter lookup
	    def initialize(extrusion=nil, parent=nil)
		@extrusion = extrusion || Model::Extrusion.new
		@parent = parent
	    end

	    # Evaluate a block in the context of an {Extrusion} and a {Skecth}
	    #  Use the trick found here http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
	    #  to allow the DSL block to call methods in the enclosing *lexical* scope
	    # @return {Extrusion}
	    def evaluate(&block)
		if block_given?
		    @sketch_builder = Sketch::Builder.new
		    @self_before_instance_eval = eval "self", block.binding
		    self.instance_eval &block
		    @extrusion.sketch = @sketch_builder.sketch
		end
		@extrusion
	    end


	    # Forward all missing method calls to the extrusion and fall through
	    #   to the {Sketch} builder. If that fails, try the parent.
	    def method_missing(method, *args, &block)
		@extrusion.send method, *args, &block
	    rescue NoMethodError
		begin
		    @sketch_builder.send method, *args, &block
		rescue NoMethodError
		    begin
			@parent.send(method, *args, &block)
		    rescue
			# The second half of the instance_eval delegation trick mentioned at
			#   http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
			@self_before_instance_eval.send method, *args, &block
		    end
		end
	    end

	    # Set the length attribute of the {Extrusion}
	    # @param length [Number]	the new length
	    def length(length)
		@extrusion.length = length
	    end

	    # Define a named parameter
	    # @param [Symbol] name	The name of the parameter
	    # @param [Proc] block	A block that evaluates to the value of the parameter
	    def let name, &block
		@extrusion.define_parameter name, &block
	    end
	end
    end
end
