require 'sketch'

require_relative 'model/builder'
require_relative 'model/extrusion'
require_relative 'model/group'

=begin
A Model is a container for 3D Geometry objects
=end

class Model
    attr_reader :elements

    def initialize(&block)
	@elements = Array.new
	instance_eval &block if block_given?
    end

# @group Accessors

    # @return [Bool]	true if the model is empty, false otherwise
    def empty?
	@elements.empty?
    end

# @endgroup

    # Adds all of the given elements to the {Model}
    # @param [Array]    args The elements to add
    # @return   The last element added
    def push(*args)
	@elements.push(*args).last
    end

    # Add an {Extrusion} object to the {Model}
    # @param [Extrusion]    extrusion	The {Extrusion} to add
    # @return [Extrusion]   A new {Extrusion}
    def add_extrusion(extrusion)
	push extrusion
    end
end
