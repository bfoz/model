require 'sketch'

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

    def add_extrusion(length, sketch)
	extrusion = Extrusion.new(sketch, length)
	@elements.push extrusion
	extrusion
    end

    private
end

def self.extrude(sketch, length)
    Model::Extrusion.new(sketch, length)
end
