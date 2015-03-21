# Geometric Modeling With Ruby [![Build Status](https://travis-ci.org/bfoz/model.png)](https://travis-ci.org/bfoz/model)

*Model* is a container for 3D [geometry](https://rubygems.org/gems/geometry) in the same way that a canvas is a container for 2D [geometry](https://rubygems.org/gems/geometry).

License
-------

Copyright 2012-2015 Brandon Fosdick <bfoz@bfoz.net> and released under the BSD license.

Examples
--------

### Extrusions

A basic extrusion that happens to look like a cylinder.

```ruby
require 'model'

cylinder = Model.new do
    extrude length:10 { circle radius:1 }
end
```

Inside the extrusion block you can use any command that's valid when building a Sketch object.

```ruby
cube = Model.new do
    extrude length:10 { square size:10 }
end
```

### Models, all the way down

Once you have a few Models made, you'll want to start using them for other things.

```ruby
Model.new do
    push cylinder, origin:[1,2,3]
    push cube, origin:[4,5,6]
end
```

### Groups

Eventually, you'll have so many sub-Models that you'll need to start grouping them.

```ruby
Model.new do
    push cube	# origin defaults to [0,0,0]
    
    group origin:[0, 0, 1] do           # Make it all float, the way bricks don't
        push cylinder, origin:[10, 10, 0]
        push cylinder, origin:[10, -10, 0]
        push cylinder, origin:[-10, -10, 0]
        push cylinder, origin:[-10, 10, 0]
    end
end
```

### Transformation

Or, you may decide that everything needs to be sideways.

```ruby
Model.new do
    group x:[1,0,0], y:[0,0,1] do        # Rotate so the Y-axis points along the +Z axis
        push cube                        # origin defaults to [0,0,0]
	
        group origin:[0, 0, 1] do        # Make it all float, the way bricks don't
            push cylinder, origin:[10, 10, 0]
            push cylinder, origin:[10, -10, 0]
            push cylinder, origin:[-10, -10, 0]
            push cylinder, origin:[-10, 10, 0]
        end
    end
end
```

If you only need to translate something, you can use the _translate_ shortcut. It creates a new group, but without any rotations.

```ruby
Model.new do
    group x:[1,0,0], y:[0,0,1] do        # Rotate so the Y-axis points along the +Z axis
        push cube                        # origin defaults to [0,0,0]
	
        translate 0, 0, 1 do             # Make it all float, the way bricks don't
            push cylinder, origin:[10, 10, 0]
            push cylinder, origin:[10, -10, 0]
            push cylinder, origin:[-10, -10, 0]
            push cylinder, origin:[-10, 10, 0]
        end
    end
end
```
