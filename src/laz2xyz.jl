using Laszip

las2dat(fname...) = laz2xyz(fname...)

"""
Read data from a LIDAR laz (laszip compressed) or las format file. Usage:

    argsout = laz2xyz(FileName::AbstractString, outType::ASCIIString="Float32", outData::ASCIIString="xyz")

    Where:
    	"FileName" Name of the input LIDAR file
    	"outType"  May either be "Float32" (default), "Float64" or "" (equivalent to Float32) and reprsents
    	           the output data type requested for the xyz components (LIDAR data may count to bilions points)
    	"outData"
    	           Select what data to output. The default is "xyz" meaning that only these three are sent out.
    	           All options include: "xyz", "xyzi", "xyzt", "xyzit" and "xyzti"
    	           where 'i' stands fot intensity (a UInt16) and 't' for GPS time (a Float64)

    The short version:
	    argsout = laz2xyz(FileName::AbstractString, outData::ASCIIString="xyz")
	is also valid and here the xyz data type defaults to Float32.

	ARGSOUT is tuple with a Mx3 xyz array plus 't' and|or 'i' depending whether they were selected or not

Example. To read the x,y,z,t data from file "lixo.laz" do:

    xyz, t = laz2xyz("lixo.laz", "xyzt")
"""

function laz2xyz(fname::AbstractString, outType::ASCIIString="Float32", argout::ASCIIString="xyz")

	# Input parsing ----------------------------------------------------------------------------
	if (!isempty(outType) && outType[1] == 'x' && argout == "xyz")		# Only two inputs, with the argout in second place.
		argout = outType;		outType = "Float32";		# Also forces outType to Float32
	end
	if !((outType == "Float32" || outType == "Float64" || outType == ""))
		error("Laszip: Output type can only be Float32 or Floar64")
	end
	if (argout != "xyz" && argout != "xyzi" && argout != "xyzt" && argout != "xyzit")
		error(@sprintf("Laszip: Wrong choice of output arguments.\nThis %s is unsupported\n
			Valid options are: xyz, or xyzi, or xyzt or xyzit", argout))
	end
	if (outType == "")		outType == "Float32"	end
	# -------------------------------------------------------------------------------------------

	laszip_reader = convert(Ptr{Ptr{Void}},pointer([pointer([0])]))
	if (laszip_create(laszip_reader) != 0)
		msgerror(laszip_reader, "creating laszip reader")
	end

	is_compressed = pointer([Cint(0)]);
	if ((laszip_open_reader(unsafe_load(laszip_reader), fname, is_compressed)) != 0)
		msgerror(laszip_reader, @sprintf("opening laszip reader for file %s", fname))
	end

	#is_compressed = unsafe_load(is_compressed)		# If equal 1 file is compressed

	header = pointer([pointer([create_empty_header()])])
	laszip_reader = unsafe_load(laszip_reader)

	if (laszip_get_header_pointer(laszip_reader, header) != 0)		# Get header pointer
		msgerror(laszip_reader, "getting header pointer from laszip reader")
	end

	# Get a pointer to the points that will be read
	point = pointer([pointer([create_empty_point()])])
	if (laszip_get_point_pointer(laszip_reader, point) != 0)
		msgerror(laszip_reader, "getting point pointer from laszip reader")
	end

	header = unsafe_load(unsafe_load(header))

	# ----------- Check if we are reading a GRID pretendind to be a regular las file ------------
	#if (header.system_identifier.d1 == UInt8('G') && header.system_identifier.d2 == UInt8('R') &&
	#    header.system_identifier.d3 == UInt8('D'))
	if (header.global_encoding == 32768)
		argout = "g"
		if (outType == "Float64")
			xyz = zeros(Float64, header.number_of_point_records*3, 1)
		else
			xyz = zeros(Float32, header.number_of_point_records*3, 1)
		end
	else
		# Pre-allocations -----------------------------------------------------------------
		if (outType != "Float64" && (header.x_scale_factor == 1 || outType == "Float32"))
			xyz = zeros(Float32, header.number_of_point_records, 3)
		else
			xyz = zeros(Float64, header.number_of_point_records, 3)
		end
		if (argout == "xyzi")
			intens = zeros(UInt16, header.number_of_point_records, 1)
		end
		if (argout == "xyzt")
			tempo  = zeros(Float64, header.number_of_point_records, 1)
		end
		if (argout == "xyzit" || argout == "xyzti")
			intens = zeros(UInt16,  header.number_of_point_records, 1)
			tempo  = zeros(Float64, header.number_of_point_records, 1)
		end
	end
	#----------------------------------------------------------------------------------

	if (argout == "xyz")
		for (k = 1:header.number_of_point_records)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1] = pt.X
			xyz[k,2] = pt.Y
			xyz[k,3] = pt.Z
		end
	elseif (argout == "xyzi")
		for (k = 1:header.number_of_point_records)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1]  = pt.X
			xyz[k,2]  = pt.Y
			xyz[k,3]  = pt.Z
			intens[k] = pt.intensity
		end
	elseif (argout == "xyzit")
		for (k = 1:header.number_of_point_records)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1]  = pt.X
			xyz[k,2]  = pt.Y
			xyz[k,3]  = pt.Z
			intens[k] = pt.intensity
			tempo[k]  = pt.gps_time
		end
	elseif (argout == "xyzt")
		for (k = 1:header.number_of_point_records)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1] = pt.X
			xyz[k,2] = pt.Y
			xyz[k,3] = pt.Z
			tempo[k] = pt.gps_time
		end
	end

	if (argout == "g")
		xyz,h = rebuild_grid(header, laszip_reader, point, xyz)
	else
		xyz = apply_scale_offset(header, xyz)
	end

	# Close the reader
	if (laszip_close_reader(laszip_reader) != 0)
		msgerror(laszip_reader, "closing laszip reader")
	end
	# Destroy the reader
	if (laszip_destroy(laszip_reader) != 0)
		msgerror(laszip_reader, "destroying laszip reader")
	end

	if (argout == "xyz")
		return xyz
	elseif (argout == "xyzi")
		return xyz, intens
	elseif (argout == "xyzt")
		return xyz, tempo
	elseif (argout == "xyzit")
		return xyz, intens, tempo
	elseif (argout == "g")			# The disgised GRID case
		return xyz,h
	end
end

# --------------------------------------------------------------------------------
function rebuild_grid(header, laszip_reader, point, z)
# Recreate a 2D array plus a 1x9 header vector as used by GMT
	n = 1;
	for (k = 1:header.number_of_point_records)
		laszip_read_point(laszip_reader)
		pt = unsafe_load(unsafe_load(point))
		z[n]    = pt.X
		z[n+1]  = pt.Y
		z[n+2]  = pt.Z
		n = n + 3
	end

	if (header.z_scale_factor != 1 && header.z_offset != 0)
		for (k = 1:3*header.number_of_point_records)
			z[k] = z[k] * header.z_scale_factor + header.z_offset
		end
	elseif (header.z_scale_factor != 1 && header.z_offset == 0)
		for (k = 1:3*header.number_of_point_records)
			z[k] *= header.z_scale_factor
		end
	end

	# Remember that this case used hijacked members of the header structure
	one = (header.project_ID_GUID_data_1 == 0 ? 1 : 0)
	#n_rows = round(Int, (header.max_x - header.min_x) / header.y_scale_factor) + one
	#n_cols = round(Int, (header.max_y - header.min_y) / header.z_scale_factor) + one
	n_rows = Int(header.project_ID_GUID_data_2)
	n_cols = Int(header.project_ID_GUID_data_3)
	x_inc  = (header.max_x - header.min_x) / (n_cols - one)
	y_inc  = (header.max_y - header.min_y) / (n_rows - one)
	
	# Now we have to find and throw away eventual extra values of the z vector
	r = 3*header.number_of_point_records - n_rows * n_cols
	if (r != 0)
		z = z[1:end-r]
	end

	z = reshape(z, n_rows, n_cols)
	h = [header.min_x header.max_x header.min_y header.max_y header.min_z header.max_z header.project_ID_GUID_data_1 x_inc y_inc]
	return z, h
end

# --------------------------------------------------------------------------------
function apply_scale_offset(header, xyz)
# ...
	if (header.x_scale_factor != 1 && (header.x_offset != 0 || header.y_offset != 0 || header.z_offset != 0))
		# Scale and offset
		for (k = 1:header.number_of_point_records)
			xyz[k,1] = xyz[k,1] * header.x_scale_factor + header.x_offset
			xyz[k,2] = xyz[k,2] * header.y_scale_factor + header.y_offset
			xyz[k,3] = xyz[k,3] * header.z_scale_factor + header.z_offset
		end
	elseif (header.x_scale_factor != 1 && header.x_offset == 0 || header.y_offset == 0 || header.z_offset == 0)
		# Scale only
		for (k = 1:header.number_of_point_records)
			xyz[k,1] *= header.x_scale_factor
			xyz[k,2] *= header.y_scale_factor
			xyz[k,3] *= header.z_scale_factor
		end
	elseif (header.x_scale_factor == 1 && (header.x_offset != 0 || header.y_offset != 0 || header.z_offset != 0))
		# Offset only
		for (k = 1:header.number_of_point_records)
			xyz[k,1] += header.x_offset
			xyz[k,2] += header.y_offset
			xyz[k,3] += header.z_offset
		end
	elseif (header.x_scale_factor != 1 || header.y_scale_factor != 1 || header.z_scale_factor != 1 ||
			header.x_offset != 0 || header.y_offset != 0 || header.z_offset != 0)
		# Probably an unforeseen case above. Just do Scale and offset
		for (k = 1:header.number_of_point_records)
			xyz[k,1] = xyz[k,1] * header.x_scale_factor + header.x_offset
			xyz[k,2] = xyz[k,2] * header.y_scale_factor + header.y_offset
			xyz[k,3] = xyz[k,3] * header.z_scale_factor + header.z_offset
		end
	end
	return xyz
end