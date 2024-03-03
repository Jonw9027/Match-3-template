extends Node2D

#grid variables

@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
#the grid off set should always the be the same size as the tiles themselves, if 32 by 32, then it should be by 32.
@export var offset: int
#the buffer is where pieces that are next are stored
@export var buffer: int

#variable on pieces
var base_piece = preload("res://Scenes/True_tile_base.tscn")
#piece data
var all_pieces = []
#the click and release positions stored.
var click_pos = Vector2 (0,0)
var release_pos = Vector2 (0,0)

#this condition is to set if it is controllable.
var controllable = false


enum State {move, wait}
@export var state = State.wait
# Called when the node enters the scene tree for the first time.
func _ready():
	all_pieces =make_2d_array(width,height)
	print(all_pieces)
	print(all_pieces[0][1])
	spawn_pieces()
	print(all_pieces)
	state = State.move

func make_2d_array(x:int, y: int):
	var array = []
	var z = 0
	for value in x:
		array.append([])
		for val in y:
			array[value].append(z)
			z +=1
	return array
# Called every frame. 'delta' is the elapsed time since the previous frame.

func spawn_pieces():
	for i in width:
		for j in height:
			var rand = floor(randf_range(0,4.99))
			var loops =0
			while(_matched(i,j,rand) && loops <100):
				rand = round(randf_range(0,4))
			var piece = base_piece.instantiate()
			piece.tile_type = rand
			add_child(piece)
			piece.position = grid_to_pixel(i,j)
			all_pieces[i][j] =piece



#double check grid to pixel pattern
func grid_to_pixel(column, row):
	var new_x = x_start + offset*column
	var new_y = y_start +-offset*row
	return Vector2(new_x,new_y)

func pixel_to_grid(pixel_x,pixel_y):
	var new_x =round((pixel_x-x_start)/offset)
	var new_y =round((pixel_y-y_start)/-offset)
	return Vector2 (new_x,new_y)


#function to check for a match.
func _matched(i, j, type):
	if i>1:
		if all_pieces[i- 1][j] != null && all_pieces[i-2][j] != null:
			if all_pieces[i -1][j].tile_type == type && all_pieces[i-2][j].tile_type == type:
				return true
	if j>1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].tile_type == type && all_pieces[i][j-2].tile_type == type:
				return true
	return false


#checks if it is in the grid.
func is_in_grid(column, row):
	if column >=0 && column <width:
		if row >=0 && row<height:
			return true
	return false
#checks if item is bordering, needs to be based on grid to work right. Based on orthogon
func is_bordering_orth(one:Vector2,two:Vector2):
	#checking x
	print("1: " + str(one) )
	print("2: " + str(two))
	if one.x == two.x:
		if abs(one.y -two.y) ==1:
			return true
	if one.y == two.y:
		if abs(one.x -two.x) == 1:
			return true
	return false


#the swap function, vectors are based on grid coordinates, not pixel coordinates.
func swap_pieces(one:Vector2,two:Vector2):
	if all_pieces[one.x][one.y] !=null && all_pieces[two.x][two.y] !=null:
		var first_piece = all_pieces[one.x][one.y]
		var second_piece = all_pieces[two.x][two.y]
		all_pieces[one.x][one.y] = second_piece
		all_pieces[two.x][two.y] = first_piece
		#this may be redundant and unnecessary code, double check.
		first_piece.move(grid_to_pixel(two.x,two.y))
		second_piece.move(grid_to_pixel(one.x,one.y))
	#this function is to start the destroy timer, mainly to be done to make it all work accordingly and more consistently.
	if(get_parent().get_node("destroy_timer").time_left>0):
		return
	get_parent().get_node("destroy_timer").start()





func _process(delta):
	touch_input()
	find_matches()
	


#this function checks for when you click and release.
func touch_input():
	#State check before starting
	if(state == State.wait):
		return
	#the function to check for when you just clicked
	if Input.is_action_just_pressed("click"):
		#this sets the click position
		click_pos = get_global_mouse_position()
		#this then converts it to a more usable form
		var click_pos_grid = pixel_to_grid(click_pos.x,click_pos.y)
		#this checks if the click is in the grid
		if is_in_grid(click_pos_grid.x,click_pos_grid.y) == true:
			controllable = true
		print(click_pos_grid)
	#the function when you just released the click.
	if Input.is_action_just_released("click"):
		#sets the release position
		release_pos = get_global_mouse_position()
		#conversion to grid
		var release_pos_grid = pixel_to_grid(release_pos.x, release_pos.y)
		print(release_pos_grid)
		#checks if the release position is  in the grid.
		if is_in_grid(release_pos_grid.x,release_pos_grid.y) == true:
			#this checks if the tile is bordering the piece orthogonally.
			if is_bordering_orth(pixel_to_grid(click_pos.x,click_pos.y),release_pos_grid) && controllable == true:
				#this then performs the swap function.
				swap_pieces(pixel_to_grid(click_pos.x,click_pos.y),release_pos_grid)
				state = State.wait 
				if(matchexists() == false):
					swap_pieces(pixel_to_grid(click_pos.x,click_pos.y),release_pos_grid)
					state = State.move 
	
	# a function may need to be added here for when other functions are placed, such as effects that move items and a means to revert back.
	
	
	#print(get_parent().get_node("destroy_timer").time_left)




# problem to resolve, get timer to start only if the original time left is 0, resolved, using an if condition.


#this function actively checks for current matches
func find_matches():
	for i in height: #for each value in height
		for j in width: #for each value in width
			if all_pieces[i][j] !=null: #if piece has value.
				var t = all_pieces[i][j].tile_type #this stores the type into the data to then use to determine if something matches
				if i>0 && i< width-1: #this checks the width and is start of horizontal match check
					if all_pieces[i+1][j] !=null && all_pieces[i-1][j] !=null: #this checks if the values are null
						if all_pieces[i-1][j].tile_type == t && all_pieces[i+1][j].tile_type ==t:
							all_pieces[i-1][j].dimmer()
							all_pieces[i][j].dimmer()
							all_pieces[i+1][j].dimmer()
				if j>0 && j< height-1:
					if all_pieces[i][j+1]!=null && all_pieces[i][j-1] != null:
						if all_pieces[i][j+1].tile_type == t && all_pieces[i][j-1].tile_type == t:
							all_pieces[i][j-1].dimmer()
							all_pieces[i][j].dimmer()
							all_pieces[i][j+1].dimmer()


#this function checks for matches if they exist or not.
func matchexists():
	for i in height: #for each value in height
		for j in width: #for each value in width
			if all_pieces[i][j] !=null: #if piece has value.
				var t = all_pieces[i][j].tile_type #this stores the type into the data to then use to determine if something matches
				if i>0 && i< width-1: #this checks the width and is start of horizontal match check
					if all_pieces[i+1][j] !=null && all_pieces[i-1][j] !=null: #this checks if the values are null
						if all_pieces[i-1][j].tile_type == t && all_pieces[i+1][j].tile_type ==t:
							return true
				if j>0 && j< height-1:
					if all_pieces[i][j+1]!=null && all_pieces[i][j-1] != null:
						if all_pieces[i][j+1].tile_type == t && all_pieces[i][j-1].tile_type == t:
							return true
	return false

func destroy_matched():
	for i in width:
		for j in height:
			if all_pieces[i][j] !=null:
				if all_pieces[i][j].matched == true:
					all_pieces[i][j].match_effect
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	
	
	if(get_parent().get_node("collapse_timer").time_left>0):
		return
	get_parent().get_node("collapse_timer").start()




func collapse():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j +1, height):
					if all_pieces[i][k] !=null:
						all_pieces[i][k].move(grid_to_pixel(i,j)) 
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("Refill_timer").start()


#the refilling of columns function.
#an idea to try is to pregenerate on a "board" above that can allow for much smoother animations.

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = floor(randf_range(0,4.99))
				var loops =0
				#adjust this function as needed if desiring possible matches
				while(_matched(i,j,rand) && loops <100):
					rand = round(randf_range(0,4))
				var piece = base_piece.instantiate()
				piece.tile_type = rand
				add_child(piece)
				piece.position = grid_to_pixel(i,j)
				all_pieces[i][j] =piece
	if(matchexists()):
		get_parent().get_node("destroy_timer").start()
		state = State.wait
	else:
		state = State.move

#these are the timers set up.


#new way to do this is going to be now based on await functions, will deprecate and swap functions probably in a future version


func _on_destroy_timer_timeout():
	destroy_matched()


func _on_collapse_timer_timeout():
	collapse()


func _on_refill_timer_timeout():
	refill_columns()
