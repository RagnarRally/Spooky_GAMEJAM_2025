extends TextureRect

# Create a local rendering device.
var rd
var shader_path := "res://shader-stuff/compute_planets.glsl"
var spirv
var shader

# Prepare our data. We use floats in the shader, so we need 32 bit.
var input := PackedFloat32Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
var input_bytes := input.to_byte_array()

# Create a storage buffer that can hold our float values.
# Each float has 4 bytes (32 bit) so 10 x 4 = 40 bytes
var buffer1
var buffer2
var buffer3
var buffer4
var buffer5
var buffer6

# Create a uniform to assign the buffer to the rendering device
var uniform_set

var uniform1 := RDUniform.new()
var uniform2 := RDUniform.new()
var uniform3 := RDUniform.new()
var uniform4 := RDUniform.new()
var uniform5 := RDUniform.new()
var uniform6 := RDUniform.new()

# output texture
var output_tex_uniform := RDUniform.new()
var output_tex := RID() 
var fmt := RDTextureFormat.new() 
var view := RDTextureView.new() 
var image_texture : ImageTexture

var pipeline

# simulation parameters 
var tex_size = 512
var num_points = 512
var shader_loc_size = 200
var arm_count :int= 10
var arm_offset :float = 1.5
var galaxy_rad = 512
var gravity = 0.00067
var dt = 0.01
var velocity_magnitude_scale :float= -0.5 #try negative

@export var color_scheme = 1

	
func starting_positions():
	var positions_in := PackedVector2Array()
	var velocity_in := PackedVector2Array()
	var mass_in := PackedFloat32Array()
	var center := Vector2(tex_size/2, tex_size/2)
	var center_mass = 5000000.0
	positions_in.append(center)
	mass_in.append(center_mass)
	
	for i in range(num_points-1):
		var mass := randf() * 5.
		var arm_index :int= i % arm_count
		var angle_offset :float= randf() * arm_offset# Randomly spread points along each arm
			
		# Calculate the angle along the spiral arm
		var angle :float= (float(arm_index) / arm_count) * TAU + angle_offset 
			
		# Random distance from center, scaled to form spirals
		var r = sqrt(randf()) * galaxy_rad
			
		# Convert polar to Cartesian and shift to center
		var point = Vector2(r * cos(angle), r * sin(angle)) + center
		
		positions_in.append(point)
		mass_in.append(mass)
		velocity_in.append(Vector2.ZERO)
		
		var distance_to_center := point.distance_to(center)
		if distance_to_center > 0: # Avoid division by zero
			var velocity_magnitude := sqrt(gravity * center_mass / distance_to_center)
			
			#manual adjust because the center star does not represent the entire mass  of the galaxy - we could sum it up to get close mass and better veloc to match
			velocity_magnitude *= velocity_magnitude_scale
			
			# Velocity direction is perpendicular to the radial direction (tangential to the circle)
			var radial_direction := (point - center).normalized()
			var tangential_direction := Vector2(-radial_direction.y, radial_direction.x) # Rotate by 90 degrees
			
			# Final velocity vector
			var velocity := tangential_direction * velocity_magnitude
			velocity_in.append(velocity)
		else:
			velocity_in.append(Vector2.ZERO)
		
	return {"positions_in": positions_in, "velocity_in": velocity_in, "mass_in": mass_in}
	
func rebuild_buffers(positions: PackedVector2Array, velocity: PackedVector2Array, mass: PackedFloat32Array, reset_image = true):
	var data1: PackedByteArray = PackedByteArray()
	data1.append_array(positions.to_byte_array())
	
	var data2 :PackedByteArray= PackedByteArray()
	data2 = data1.duplicate() # position out
	
	var data3: PackedByteArray = PackedByteArray()
	data3.append_array(velocity.to_byte_array())
	
	var data4 :PackedByteArray= PackedByteArray()
	data4 = data3.duplicate() # velocity out
	
	var data5: PackedByteArray = PackedByteArray()
	data5.append_array(mass.to_byte_array())
	
	var data6 :PackedByteArray= PackedByteArray()
	data6 = data5.duplicate() # mass out
	
	buffer1 = rd.storage_buffer_create(data1.size(), data1)
	buffer2 = rd.storage_buffer_create(data2.size(), data2)
	buffer3 = rd.storage_buffer_create(data3.size(), data3)
	buffer4 = rd.storage_buffer_create(data4.size(), data4)
	buffer5 = rd.storage_buffer_create(data5.size(), data5)
	buffer6 = rd.storage_buffer_create(data6.size(), data6)
	
	var output_image := Image.create(tex_size, tex_size, false, Image.FORMAT_RGBAF)
	image_texture = ImageTexture.create_from_image(output_image)
	texture = image_texture
	output_tex = rd.texture_create(fmt, view, output_image.get_data())
	
	uniform1.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform1.binding = 0 # this needs to match the "binding" in our shader file
	uniform1.add_id(buffer1)
	
	uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform2.binding = 1 # this needs to match the "binding" in our shader file
	uniform2.add_id(buffer2)
	
	output_tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_tex_uniform.binding = 2
	output_tex_uniform.add_id(output_tex)
	
	uniform3.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform3.binding = 3 # this needs to match the "binding" in our shader file
	uniform3.add_id(buffer3)
	
	uniform4.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform4.binding = 4 # this needs to match the "binding" in our shader file
	uniform4.add_id(buffer4)
	
	uniform5.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform5.binding = 5 # this needs to match the "binding" in our shader file
	uniform5.add_id(buffer5)
	
	uniform6.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform6.binding = 6 # this needs to match the "binding" in our shader file
	uniform6.add_id(buffer6)
	
	uniform_set = rd.uniform_set_create([uniform1, uniform2, output_tex_uniform, uniform3, uniform4, uniform5, uniform6], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	pipeline = rd.compute_pipeline_create(shader)

func _ready() -> void:
	# rendering device
	rd = RenderingServer.create_local_rendering_device()
	
	#shader
	var shader_file := load("res://shader-stuff/compute_planets.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	fmt = RDTextureFormat.new()
	fmt.width = tex_size
	fmt.height = tex_size
	fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT \
					| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT \
					| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT \
					| RenderingDevice.TEXTURE_USAGE_CPU_READ_BIT
	view = RDTextureView.new()
	
	var positions = starting_positions()
	rebuild_buffers(positions['positions_in'], positions['velocity_in'], positions['mass_in'], true)


func _process(delta: float) -> void:
	var output_bytes_pos :PackedByteArray
	var output_bytes_veloc :PackedByteArray
	var output_bytes_mass :PackedByteArray
	var byte_data : PackedByteArray
	var image :Image
	var compute_list
	var params :PackedInt32Array
	var params_bytes :PackedByteArray
	var global_size = (num_points/shader_loc_size)+1
	
	# drawing pass
	compute_list = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	
	params =  PackedInt32Array([num_points, 0, 0, 0]) # padded to multiple of 4 floats when needed
	var num_points_bytes = PackedInt32Array([num_points]).to_byte_array()
	var gravity_bytes = PackedFloat32Array([gravity]).to_byte_array()
	var dt_bytes = PackedFloat32Array([dt]).to_byte_array()
	var color_scheme_bytes = PackedInt32Array([color_scheme]).to_byte_array()
	params_bytes.append_array(num_points_bytes)
	params_bytes.append_array(gravity_bytes)
	params_bytes.append_array(dt_bytes)
	params_bytes.append_array(color_scheme_bytes)
	rd.compute_list_set_push_constant(compute_list,params_bytes,params_bytes.size())
	rd.compute_list_dispatch(compute_list, global_size, 1, 1)
	rd.compute_list_end()
	rd.submit()
	rd.sync()
	
	# outputs
	output_bytes_pos = rd.buffer_get_data(buffer2)
	output_bytes_veloc = rd.buffer_get_data(buffer4)
	output_bytes_mass = rd.buffer_get_data(buffer6)
	
	rd.buffer_update(buffer1, 0, output_bytes_pos.size(), output_bytes_pos)
	rd.buffer_update(buffer3, 0, output_bytes_pos.size(), output_bytes_veloc)
	rd.buffer_update(buffer5, 0, output_bytes_pos.size(), output_bytes_mass)
	
	#set texture
	byte_data = rd.texture_get_data(output_tex, 0)
	image = Image.create_from_data(tex_size, tex_size, false, Image.FORMAT_RGBAF, byte_data)
	image_texture = ImageTexture.create_from_image(image)
	texture = image_texture
	# Submit to GPU and wait for sync

func _exit_tree() -> void:
	if buffer1.is_valid():
		rd.free_rid(buffer1)
	if buffer2.is_valid():
		rd.free_rid(buffer2)
	if output_tex.is_valid():
		rd.free_rid(output_tex)
	if pipeline.is_valid():
		rd.free_rid(pipeline)
	if uniform_set.is_valid():
		rd.free_rid(uniform_set)
	if shader.is_valid():
		rd.free_rid(shader)
	rd.free()
