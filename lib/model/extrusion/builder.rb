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
	    # @return {Extrusion}
	    def evaluate(&block)
		@sketch_builder = Sketch::Builder.new
		instance_eval &block if block_given?
		@extrusion.sketch = @sketch_builder.sketch
		@extrusion
	    end

	    # Define a named parameter
	    # @param [Symbol] name	The name of the parameter
	    # @param [Proc] block	A block that evaluates to the value of the parameter
	    def let name, &block
		@extrusion.define_parameter name, &block
	    end

	    # Forward all missing method calls to the extrusion and fall through
	    #   to the {Sketch} builder. If that fails, try the parent.
	    def method_missing(id, *args, &block)
		@extrusion.send id, *args, &block
	    rescue NoMethodError
		begin
		    @sketch_builder.send id, *args, &block
		rescue NoMethodError
		    @parent.send(id, *args, &block) if @parent
		end
	    end
	end
    end
end
