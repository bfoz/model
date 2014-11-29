require_relative 'group'

=begin
{Layout} is a container that arranges its child elements in the specified
direction and, optionally, with the specified spacing.

For example, to create two cubes stacked on top of each other, use:

    Layout.new :vertical do
        push Extrusion.new(length:5) { ... }
        push Extrusion.new(length:5) { ... }
    end

To add a bit of space between each cube...

    Layout.new :vertical, space:1 do
        push Extrusion.new(length:5) { ... }
        push Extrusion.new(length:5) { ... }
    end
=end
class Model
    class Layout < Group
	# @return [Symbol] alignment	the layout alignment (:top, :bottom, :left, :right, :front, :back)
	attr_reader :alignment

	# @return [Symbol] direction    the layout direction (either :horizontal, :vertical, or :lateral)
	attr_reader :direction

	# @return [Number] spacing	the spacing to add between each element
	attr_reader :spacing

	# @param direction  [Symbol]	the layout direction
	# @param alignment  [Symbol]	the alignment to use in the direction perpendicular to the layout direction
	# @param spacing    [Number]	the space to leave between each element
	def initialize(*args, **options, &block)
	    # Find any bare direction arguments
	    options[:direction] = args.find {|arg| [:horizontal, :vertical, :lateral].include? arg }

	    # Find any bare alignment arguments
	    aligns = args.find_all {|arg| [:top, :bottom, :left, :right, :front, :back].include? arg }
	    options[:alignment] = (aligns.length <= 1) ? aligns.first : aligns

	    @direction = options.delete(:direction) || :vertical
	    @alignment = options.delete(:align) || options.delete(:alignment)
	    @spacing = options.delete(:spacing) || 0

	    if ((direction == :vertical) && ((alignment == :top) || (alignment == :bottom))) ||
		((direction == :horizontal) && ((alignment == :left) || (alignment == :right))) ||
		((direction == :lateral) && ((alignment == :front) || (alignment == :back)))
		raise ArgumentError, "Alignment can't be #{alignment} when direction is #{direction}"
	    end

	    super *args, **options, &block
	end

	# Any pushed element that doesn't have a transformation property will be wrapped in a {Group}.
	# @param element [Geometry] the geometry element to append
	# @return [Layout]
	def push(element, *args)
	    max = last ? last.max : Point.zero

	    offset = make_offset(element, max)

	    if offset == Point.zero
		super element, *args
	    else
		if element.respond_to?(:transformation=)
		    super element, *args
		else
		    super Group.new.push element, *args
		end

		last.transformation.translate(offset)
	    end
	    self
	end

	private

	def make_offset(element, max)
	    element_min = element.min
	    case direction
		when :horizontal
		    y_offset = case alignment
			when :front then    -element_min.y
			when :back  then    -element.max.y
			else	# center
			    0
		    end
		    z_offset = case alignment
			when :bottom	then    -element_min.z
			when :top	then    -element.max.z
			else	# center
			    0
		    end
		    Point[max.x - element_min.x + (elements.empty? ? 0 : spacing), y_offset, z_offset]

		when :lateral
		    x_offset = case alignment
			when :left  then    -element_min.x
			when :right then    -element.max.x
			else	# center
			0
		    end
		    z_offset = case alignment
			when :bottom	then    -element_min.z
			when :top	then    -element.max.z
			else	# center
			0
		    end
		    Point[x_offset, max.y - element_min.y + (elements.empty? ? 0 : spacing), z_offset]

		when :vertical
		    x_offset = case alignment
			when :left  then    -element_min.x
			when :right then    -element.max.x
			else
			    0
		    end
		    y_offset = case alignment
			when :front then    -element_min.y
			when :back  then    -element.max.y
			else	# center
			    0
		    end
		    Point[x_offset, y_offset, max.z - element_min.z + (elements.empty? ? 0 : spacing)]
	    end
	end
    end
end
