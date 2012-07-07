require 'sketch'

require_relative 'model/builder'
require_relative 'model/extrusion'

=begin
A Model is a container for 3D Geometry objects
=end

class Model
    attr_reader :elements

    def initialize(&block)
	@elements = Array.new
    end

# @group Accessors

    # @return [Bool]	true if the model is empty, false otherwise
    def empty?
	@elements.empty?
    end

# @endgroup

    # Add an {Extrusion} object to the {Model}
    # @param [Extrusion]    extrusion	The {Extrusion} to add
    # @return [Extrusion]   A new {Extrusion}
    def add_extrusion(extrusion)
	@elements.push extrusion
	extrusion
    end
end
