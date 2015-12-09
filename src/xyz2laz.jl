using Laszip

"""
Write XYZ data to a LIDAR laz (laszip compressed) or las format file. Usage:

	laz2xyz(FileName::AbstractString, outType::ASCIIString="Float32", outData::ASCIIString="xyz")

	Where:
		"FileName" Name of the output LIDAR file
		"outType"  May either be "Float32" (default), "Float64" or "" (equivalent to Float32) and reprsents
				   the output data type requested for the xyz components (LIDAR data may count to bilions points)
		"outData"
				   Select what data to output. The default is "xyz" meaning that only these three are sent out.
				   All options include: "xyz", "xyzi", "xyzt", "xyzit" and "xyzti"
				   where 'i' stands fot intensity (a UInt16) and 't' for GPS time (a Float64)

	The short version:
		argsout = las2xyz(FileName::AbstractString, outData::ASCIIString="xyz")
	is also valid and here the xyz data type defaults to Float32.

Example. To read the x,y,z,t data from file "lixo.laz" do:

	xyz, t = las2xyz("lixo.laz", "xyzt")
"""

function xyz2laz(fname::AbstractString, xyz)

	n_rows, ncols = size(xyz)

	#  Create the writer
	laszip_writer = convert(Ptr{Ptr{Void}},pointer([pointer([0])]))
	if (laszip_create(laszip_writer) != 0)
		error("creating laszip writer")
	end

	header = pointer([pointer([create_empty_header()])])    # Get an empty header directly from C
	laszip_writer = unsafe_load(laszip_writer)

	if (laszip_get_header_pointer(laszip_writer, header) != 0)      # Get the header pointer
		error("getting header pointer from laszip writer")
	end

	hdr = unsafe_load(unsafe_load(header))      # Get back the straight type

	# Populate the header
	hdr.version_major = 1
	hdr.version_minor = 2
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

	# Save back the header to its C pointer
	unsafe_store!(unsafe_load(header), hdr)

	if (laszip_open_writer(laszip_writer, fname, 1) != 0)
		pStr = pointer([pointer(lpad("",256,"    "))])
		laszip_get_error(laszip_writer, pStr)
		Str = bytestring(unsafe_load(pStr))
		error(@sprintf("opening laszip writer for %s\n\tMSG: %s", fname, Str))
	end

	# Get a pointer to the points that will be written
	point = pointer([pointer([create_empty_point()])])
	if (laszip_get_point_pointer(laszip_writer, point) != 0)
		error("getting point pointer from laszip writer")
	end
	point = unsafe_load(point)

	coordinates = zeros(3)
	for (count = 1:n_rows)
		#pt = unsafe_load(point)
		#pt.X = round(Int32, xyz[count,1]*100)
		#pt.Y = round(Int32, xyz[count,2]*100)
		#pt.Z = round(Int32, xyz[count,3]*100)
		#unsafe_store!(point, pt)
		coordinates[1] = xyz[count,1]
		coordinates[2] = xyz[count,2]
		coordinates[3] = xyz[count,3]
		laszip_set_coordinates(laszip_writer, convert(Ptr{Cdouble}, pointer(coordinates)))
		laszip_write_point(laszip_writer)
	end

	# Close the writer
	if (laszip_close_writer(laszip_writer) != 0)
		error("closing laszip writer")
	end
	# Destroy the writer
	if (laszip_destroy(laszip_writer) != 0)
		error("destroying laszip writer")
	end

end