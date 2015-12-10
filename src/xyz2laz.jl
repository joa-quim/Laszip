using Laszip

"""
Write XYZ data to a LIDAR laz (laszip compressed) or las format file. Usage:

	xyz2laz(FileName::AbstractString, xyz)

	Where:
		"FileName" Name of the output LIDAR file
		xyz  A Mx3 array with the point coordinates

Example. To write the x,y,z data to file "lixo.laz" do:

	xyz2laz("lixo.laz", xyz)
"""

function xyz2laz(fname::AbstractString, xyz)

	n_rows, ncols = size(xyz)

	#  Create the writer
	laszip_writer = convert(Ptr{Ptr{Void}},pointer([pointer([0])]))
	if (laszip_create(laszip_writer) != 0)
		msgerror(laszip_writer, "creating laszip writer")
	end

	header = pointer([pointer([create_empty_header()])])    # Get an empty header directly from C
	laszip_writer = unsafe_load(laszip_writer)

	if (laszip_get_header_pointer(laszip_writer, header) != 0)      # Get the header pointer
		msgerror(laszip_writer, "getting header pointer from laszip writer")
	end

	hdr = unsafe_load(unsafe_load(header))      # Get back the straight type

	# Populate the header
	hdr.version_major = 1
	hdr.version_minor = 2
	hdr.point_data_format = 1
	hdr.number_of_point_records = n_rows
	hdr.x_scale_factor = 1.0
	hdr.y_scale_factor = 1.0
	hdr.z_scale_factor = 1.0
	min_x, min_y, min_z = minimum(xyz, 1)
	max_x, max_y, max_z = maximum(xyz, 1)
	hdr.max_x = max_x
	hdr.min_x = min_x
	hdr.max_y = max_y
	hdr.min_y = min_y
	hdr.max_z = max_z
	hdr.min_z = min_z

	# ----------------- Find reasonable scale_factor and offset -----------------------------------------
	if (hdr.min_x >= -360 && hdr.max_x <= 360 && hdr.min_y >= -90 && hdr.max_y <= 90)	# Assume geogs
		hdr.x_scale_factor = 1e-7
		hdr.y_scale_factor = 1e-7
	else
		hdr.x_scale_factor = 1e-3
		hdr.y_scale_factor = 1e-3
	end
	hdr.z_scale_factor = 1e-3

	if (!isnan(hdr.min_x) && isnan(!hdr.max_x))
		hdr.x_offset = (floor((hdr.min_x + hdr.max_x)/hdr.x_scale_factor/20000000)) * 10000000 * hdr.x_scale_factor
	end
	if (!isnan(hdr.min_y) && isnan(!hdr.max_y))
		hdr.y_offset = (floor((hdr.min_y + hdr.max_y)/hdr.y_scale_factor/20000000)) * 10000000 * hdr.y_scale_factor
	end
	if (!isnan(hdr.min_z) && isnan(!hdr.max_z))
		hdr.z_offset = (floor((hdr.min_z + hdr.max_z)/hdr.z_scale_factor/20000000)) * 10000000 * hdr.z_scale_factor
	end
	# ---------------------------------------------------------------------------------------------------

	# Save back the header to its C pointer
	unsafe_store!(unsafe_load(header), hdr)

	if (laszip_open_writer(laszip_writer, fname, 1) != 0)
		msgerror(laszip_writer, @sprintf("opening laszip writer for %s", fname))
	end

	# Get a pointer to the points that will be written
	point = pointer([pointer([create_empty_point()])])
	if (laszip_get_point_pointer(laszip_writer, point) != 0)
		msgerror(laszip_writer, "getting point pointer from laszip writer")
	end
	point = unsafe_load(point)

	coordinates = zeros(3)
	for (count = 1:n_rows)
		pt = unsafe_load(point)
		pt.X = round(Int32, (xyz[count,1]-hdr.x_offset) * hdr.x_scale_factor)
		pt.Y = round(Int32, (xyz[count,2]-hdr.y_offset) * hdr.y_scale_factor)
		pt.Z = round(Int32, (xyz[count,3]-hdr.z_offset) * hdr.z_scale_factor)
		unsafe_store!(point, pt)
		#coordinates[1] = xyz[count,1]
		#coordinates[2] = xyz[count,2]
		#coordinates[3] = xyz[count,3]
		#laszip_set_coordinates(laszip_writer, convert(Ptr{Cdouble}, pointer(coordinates)))
		laszip_write_point(laszip_writer)
	end

	# Close the writer
	if (laszip_close_writer(laszip_writer) != 0)
		msgerror(laszip_writer, "closing laszip writer")
	end
	# Destroy the writer
	if (laszip_destroy(laszip_writer) != 0)
		msgerror(laszip_writer, "destroying laszip writer")
	end

end