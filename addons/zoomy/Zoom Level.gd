tool
extends Container

const DEBUG_VERBOSE = false

var editorb=EditorInterface #The EditorInterface sent to us from the plugin activation
var _activated = false


onready var editor_node = get_node("/root/EditorNode")
onready var editor_canvas = find_viewport(editor_node,0, "CanvasItemEditor")
onready var viewport  = find_viewport(editor_canvas,0,"Viewport")


func _ready():
#	$icon_viewport_zoom.position.x = self.rect_size.x - 16
	pass
	
#Used to ready the addon once the editor interface has been acquired from host
func activate():  
	_activated = true 
	#listKids(viewport,0)
	refresh(self)
	set_physics_process(true)

#Done every frame. I wonder if there's a way to only do it on the proper signals?
func _physics_process(delta):
	
	if _activated:
		#Don't remember if this stuff is necessary.  Might be here for future use
		#if EditorInterface can expose the 2d viewport without nasty hacks
		var root=editorb.get_base_control()
		var r = root.get_global_rect()

		if viewport !=null:
			var zoom = viewport.get_final_transform().get_scale().x * 100
			var mpos = viewport.get_mouse_position()
			
			$TextureRect2.rect_position.x = $TextureRect.rect_position.x - $TextureRect2.rect_size.x - 32
			
			$TextureRect/Z.text = "%*.*f%%" % [7,1,zoom]
			$TextureRect2/pos.text = "(%.f, %.f)" % [mpos.x, mpos.y]
			

#in case something goes horribly wrong!
func refresh(from_whom):
	if DEBUG_VERBOSE: print ("zoomy refresh!")
	
	#Let's find the canvas viewport, LIKE A WRECKING BALL
	editor_canvas = find_viewport($'/root/EditorNode', 0 ,"CanvasItemEditor")
	viewport = find_viewport(editor_canvas, 0, "Viewport", DEBUG_VERBOSE) # Returns null if not found


#FIND THE EDITOR VIEWPORT
func find_viewport(node, recursive_level, className, debugPrint=false):
	if node == null:
		print("null bad! %s, %s" % [recursive_level, className])
		return null
	if node.get_class() == className:
		if DEBUG_VERBOSE: print( "%s Found." % className)
		return node
#	elif node.get_class().begins_with(className):
#		print(node.get_class() + " ..right?")
#		pass
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			if debugPrint == true: print(repeat_str(recursive_level) + "Child: %s (%s)" % [child.name, child.get_class()])
			var result = find_viewport(child, recursive_level, className)
			if result != null:
				return result

#DEBUG ONLY, this is used to inspect the root tree so we can see what's in there.
func listKids(node, recursive_level):
	recursive_level +=1
	if recursive_level >15:
		return null
	for child in node.get_children():
		print(repeat_str(recursive_level) + "Child: %s (%s)" % [child.name, child.get_class()])
		var result = listKids(child,recursive_level)
		if result != null:
			return result
			
#This function is dumb.  It only repeats spaces because reasons
func repeat_str(length):
	return ('%' + String(length*4) + 'c') % 33
