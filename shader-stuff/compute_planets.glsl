#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 512, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer InPosBuffer {
    vec2 data[];
}
in_pos_buffer;

layout(set = 0, binding = 1, std430) restrict buffer OutPosBuffer {
    vec2 data[];
}
out_pos_buffer;

layout(set = 0, binding = 2, rgba32f) restrict writeonly uniform image2D OUTPUT_TEXTURE;

layout(set = 0, binding = 3, std430) restrict buffer InVelocBuffer {
    vec2 data[];
}
in_veloc_buffer;

layout(set = 0, binding = 4, std430) restrict buffer OutVelocBuffer {
    vec2 data[];
}
out_veloc_buffer;

layout(set = 0, binding = 5, std430) restrict buffer InMassBuffer {
    float data[];
}
in_mass_buffer;

layout(set = 0, binding = 6, std430) restrict buffer OutMassBuffer {
    float data[];
}
out_mass_buffer;

layout(push_constant, std430) uniform Params {
	int num_points;
    float gravity;
    float dt;
    int color_scheme;
} params;

void draw_circle(vec2 centre, float radius, vec4 color) {

    ivec2 tex_size = imageSize(OUTPUT_TEXTURE);
    int min_x = max(0, int(floor(centre.x - radius)));
    int min_y = max(0, int(floor(centre.y - radius)));
    int max_x = min(tex_size.x - 1, int(ceil(centre.x + radius)));
    int max_y = min(tex_size.y - 1, int(ceil(centre.y + radius)));
    
    float radius_sq = radius * radius;
    
    for(int i = min_x; i <= max_x; i++) {
         for(int j = min_y; j <= max_y; j++) {
            vec2 pixel_pos = vec2(float(i), float(j));
            float dist_sq = dot(pixel_pos - centre, pixel_pos - centre);
            
            if (dist_sq <= radius_sq) {
                imageStore(OUTPUT_TEXTURE, ivec2(i, j), color);
            }
         }
    }
}


void main() {
    // gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups

	bool is_center = (gl_GlobalInvocationID.x == 0);
	if (gl_GlobalInvocationID.x > params.num_points) return;	

    vec2 my_pos = in_pos_buffer.data[gl_GlobalInvocationID.x].xy;
	vec2 my_vel = in_veloc_buffer.data[gl_GlobalInvocationID.x].xy;
	float my_mass = in_mass_buffer.data[gl_GlobalInvocationID.x];

    // update simulation !

    float my_radius =  pow(my_mass, 1.0 / 3.0);

    vec2 total_force = vec2(0.0, 0.0);

    for (uint i = 0; i < in_pos_buffer.data.length(); i++) {
		if (i != gl_GlobalInvocationID.x) { // Avoid self-interaction

            vec2 neighbour_pos = in_pos_buffer.data[i].xy;
            float neighbour_mass = in_mass_buffer.data[i];

            if (abs(neighbour_mass) > 0.00001) {
                float neighbour_radius =  pow(neighbour_mass, 1.0 / 3.0);

                vec2 dir = neighbour_pos - my_pos;
                float dist = length(dir);

                float comb_radius = my_radius + neighbour_radius;

                if (dist < 0.001) {
                    // should be collision merge ??
                    if (my_mass <= neighbour_mass) {
                        	//float new_mass = my_mass + neighbour_mass;
						   // vec2 new_velocity = (my_vel * my_mass + in_veloc_buffer.data[i].xy * neighbour_mass) / new_mass;

                           // out_mass_buffer.data[i] = new_mass; // possible conflict
                           // out_veloc_buffer.data[i].xy = new_velocity; // possible conflict

                            // Zero out the smaller object
                          //  out_mass_buffer.data[gl_GlobalInvocationID.x] = 0.0;
                           // out_veloc_buffer.data[gl_GlobalInvocationID.x].xy = vec2(0.0, 0.0);

                           // break;
                    }
                }

                if (dist < 0.0001) {
                    dist += 0.0001;
                }
                float force_magnitude = params.gravity * (my_mass * neighbour_mass) / (dist * dist);

                if (force_magnitude >= 10) {
                    force_magnitude = 10.;
                }

				// Compute force vector and accumulate it
				vec2 unit_direction = normalize(dir);
				vec2 force = unit_direction * force_magnitude;

				
				//if (i == 0) {
                   // total_force += force;
               // } // hack to only give grav from center obj
				total_force += force;
            }
        }
    }

    vec2 prev_pos = my_pos;
    vec2 prev_veloc = my_vel;
    float prev_mass = my_mass;

    my_pos = out_pos_buffer.data[gl_GlobalInvocationID.x].xy;
	my_vel = out_veloc_buffer.data[gl_GlobalInvocationID.x].xy;
	my_mass = out_mass_buffer.data[gl_GlobalInvocationID.x];

    float radius = pow(my_mass, 1.0 / 3.0);
    float previous_radius = pow(prev_mass, 1.0 / 3.0);

	// Compute the acceleration (a = F / m)
	vec2 acceleration = total_force / my_mass;

	// Update velocity and position
	vec2 new_velocity = my_vel + acceleration * params.dt;
	vec2 new_position = my_pos + new_velocity * params.dt;

	// If it's the center object, it doesn't move
	if (is_center) {
		new_velocity = vec2(0, 0);
		new_position = my_pos;
	}

	// Write back updated values to the output buffers
	out_pos_buffer.data[gl_GlobalInvocationID.x].xy = new_position;
	out_veloc_buffer.data[gl_GlobalInvocationID.x].xy = new_velocity;
	out_mass_buffer.data[gl_GlobalInvocationID.x] = my_mass;

    // drawing
    vec4 color_centre;
    vec4 color_small;
    vec4 color_medium;

    if (params.color_scheme == 1) {
        color_small = vec4(1.0, 1.0, 1.0, 1.0);
        color_centre = vec4(1.0, 1.0, 0.0, 1.0);
        color_medium = vec4(1.0, 0.8, 0.0, 1.0); 
    }

    if (params.color_scheme == 2) {
        color_small = vec4(1.0, 1.0, 1.0, 1.0);
        color_centre = vec4(0.6, 0.5, 1.0, 1.0);
        color_medium = vec4(0.9, 0.5, 1.0, 1.0); 
    }

    if (params.color_scheme == 3) {
        color_small = vec4(1.0, 1.0, 1.0, 1.0);
        color_centre = vec4(0.0, 0.5, 1.0, 1.0);
        color_medium = vec4(0.0, 1.0, 0.45, 1.0); 
    }

    if (my_mass > 0.0 && !is_center) {
        draw_circle(my_pos, previous_radius, vec4(0.0, 0.0, 0.0, 0.0)); // Transparent erase
    }


    if (my_mass > 0.0 && !is_center) {
        if (my_mass > 2.) {
            draw_circle(new_position, radius,color_medium);
        }
        else {
            draw_circle(new_position, radius,color_small);
        }
    }

    if (is_center) {
        draw_circle(my_pos, 5., color_centre);
    }
}