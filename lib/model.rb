require 'sketch'

require_relative 'model/builder'
require_relative 'model/extrusion'
require_relative 'model/group'
require_relative 'model/layout'

=begin
A Model is a container for 3D Geometry objects
=end

class Model
    attr_reader :elements
    attr_accessor :transformation

    # Define a class parameter
    # @param [Symbol] name  The name of the parameter
    # @param [Proc] block   A block that evaluates to the desired value of the parameter
    def self.define_parameter name, &block
	define_method name do
	    @parameters ||= {}
	    @parameters.fetch(name) { |k| @parameters[k] = instance_eval(&block) }
	end
    end

    def initialize(*args, &block)
	options, args = args.partition {|a| a.is_a? Hash}
	options = options.reduce({}, :merge)

	@elements = Array.new

	self.transformation = options.delete(:transformation) || Geometry::Transformation.new(options.select {|k,v| [:angle, :move, :origin, :rotate, :scale, :x, :y, :z].include? k })
	options.reject! {|k,v| [:angle, :move, :origin, :rotate, :scale, :x, :y, :z].include? k }
	options.each { |k,v| send("#{k}=", v) }

	instance_eval &block if block_given?
    end

# @group Accessors

    # @return [Bool]	true if the model is empty, false otherwise
    def empty?
	@elements.empty?
    end

    # !@attribute [r] first
    #   @return [Element] The first element
    def first
	elements.first
    end

    # @!attribute last
    #   @return [Element]  The last element
    def last
	elements.last
    end

    # @attribute [r] max
    # @return [Point]
    def max
	minmax.last
    end

    # @attribute [r] min
    # @return [Point]
    def min
	minmax.first
    end

    # @attribute [r] minmax
    # @return [Array<Point>]
    def minmax
	return [nil, nil] unless @elements.size != 0

	memo = @elements.map {|e| e.minmax }.reduce {|memo, e| [memo.first.min(e.first), memo.last.max(e.last)] }
	if self.transformation
	    if self.transformation.has_rotation?
		# If the transformation has a rotation, convert the minmax into a bounding box, rotate it, then find the new minmax
		bottom = memo.first.shift(2).to_a.product(memo.last.shift(2).to_a).map {|(x,y)| Point[x, y, memo.first.z] }
		top = memo.first.shift(2).to_a.product(memo.last.shift(2).to_a).map {|(x,y)| Point[x, y, memo.last.z] }
		points = [*bottom, *top].map {|point| self.transformation.transform(point) }

		points.reduce([points[0], points[0]]) {|memo, e| [memo.first.min(e), memo.last.max(e)] }
	    else
		memo.map {|point| self.transformation.transform(point) }
	    end
	else
	    memo
	end
    end

    # @attribute [r] size
    # @return [Size]	The size of the {Rectangle} that bounds all of the {Sketch}'s elements
    def size
	Geometry::Size[self.minmax.reverse.reduce(:-).to_a]
    end

# @endgroup

    # Define an instance parameter
    # @param [Symbol] name	The name of the parameter
    # @param [Proc] block	A block that evaluates to the desired value of the parameter
    def define_parameter name, &block
	singleton_class.send :define_method, name do
	    @parameters ||= {}
	    @parameters.fetch(name) { |k| @parameters[k] = instance_eval(&block) }
	end
    end

    # Adds all of the given elements to the {Model}
    #  Optionally accepts all of the options for {Geometry::Transformation}
    # @param [Model] element	The element to add to the {Model}
    # @param [Array] args	All remaining arguments are passed the element
    # @return   The last element added
    def push(element, *args)
	if element.is_a? Class
	    @elements.push(element.new(*args)).last
	else
	    options, args = args.partition {|a| a.is_a? Hash}
	    options = options.reduce({}, :merge)
	    if options and (options.size != 0)
		element.transformation = Geometry::Transformation.new options
	    end
	    @elements.push(element).last
	end
    end
end
