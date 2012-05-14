require 'sketch'

require_relative 'model/extrusion'

=begin
A Model is a container for 3D Geometry objects
=end

module Model
    def self.extrude(sketch, length)
	Model::Extrusion.new(sketch, length)
    end
end
