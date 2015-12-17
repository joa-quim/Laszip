using Laszip

laz2xyz(fname...) = las2dat(fname...)

"""
Read data from a LIDAR laz (laszip compressed) or las format file. Usage:

	argsout = las2dat(FileName::AbstractString, opts::ASCIIString="-Fxyz")

	Where:
		"FileName" -> Name of the input LIDAR file
		"opts"     -> "-F<args>" "-T64" "-Nstart/stop" "-Cclass"

	            Select what data to output. The default is "-Fxyz" meaning that only these three are sent out.
	            Some examples include: "-Fxyz", "-Fxy", "-Fyx", "-Fz", "-Fxyzi", "-Fxyzt", "-Fxyzit", "-Fxyzti"
	                "-Fxyzic", "-Fxyzc", "-FRGB", "-FRGBI"
	            where 'i' stands for intensity (UInt16), 'c' for classification (Int8) and 't' for GPS time (Float64)

	            The float components (xyz) may be required in Float32 (the default) or in Float64. That is
	            controled by the -T option as in "-T64". This option adds to the components above and by
	            leaving a space between option. Example: xyz = las2dat("lixo.laz", "-Fxyz -T64")

	            "-Nstart/stop" Restrict the output to the points from start to stop

	            "-Cclass"  Restrict the output to the points belonging to the classification 'class'
	                       This option implies two passes, with the first for counting the number of points in class

    The short version:
	    argsout = las2dat(FileName::AbstractString)
	is also valid and here the xyz data type defaults to Float32.

	ARGSOUT is tuple with a Mx3 xyz array plus 't' and|or 'i' depending whether they were selected or not

Example. To read the x,y,z,t data from file "lixo.laz" do:

	xyz, t = las2dat("lixo.laz", "-Fxyzt")
"""

function las2dat(fname::AbstractString, opts::ASCIIString="-Fxyz")

	if (isempty(opts))
		error("Empty options string is BIG ERROR. Bye, Bye.")
	end

	laszip_reader = convert(Ptr{Ptr{Void}},pointer([pointer([0])]))
	if (laszip_create(laszip_reader) != 0)
		msgerror(laszip_reader, "creating laszip reader")
	end

	is_compressed = pointer([Cint(0)]);
	if ((laszip_open_reader(unsafe_load(laszip_reader), fname, is_compressed)) != 0)
		msgerror(laszip_reader, @sprintf("opening laszip reader for file %s", fname))
	end

	#is_compressed = unsafe_load(is_compressed)		# If equal 1 file is compressed

	#header = pointer([pointer([create_empty_header()])])
	header = pointer([pointer([create_header()])])
	laszip_reader = unsafe_load(laszip_reader)

	if (laszip_get_header_pointer(laszip_reader, header) != 0)		# Get header pointer
		msgerror(laszip_reader, "getting header pointer from laszip reader")
	end

	# Get a pointer to the points that will be read
	#point = pointer([pointer([create_empty_point()])])
	point = pointer([pointer([create_point()])])
	if (laszip_get_point_pointer(laszip_reader, point) != 0)
		msgerror(laszip_reader, "getting point pointer from laszip reader")
	end

	header = unsafe_load(unsafe_load(header))

	# Input parsing ----------------------------------------------------------------------------------
	argout, outType, class, firstPT, lastPT = parse_inputs_las2dat(header, point, laszip_reader, opts)
	totalNP = lastPT - firstPT + 1
	# ------------------------------------------------------------------------------------------------

	# ----------- Check if we are reading a GRID pretendind to be a regular las file -------------
	#if (header.system_identifier.d1 == UInt8('G') && header.system_identifier.d2 == UInt8('R') &&
	#    header.system_identifier.d3 == UInt8('D'))
	fType = Float32
	if (outType == 64)	fType = Float64		end

	if (header.global_encoding == 32768)
		argout = "g"
		xyz = zeros(fType, lastPT * 3, 1)
	else
		# ------ Pre-allocations ---------------------------------------------------------------------
		if (!isempty(search(argout,"xyz")) || !isempty(search(argout,"yxz")))
			xyz = zeros(fType, totalNP, 3)
		elseif (!isempty(search(argout,"xy")) || !isempty(search(argout,"yx")))
			xyz = zeros(fType, totalNP, 2)
		elseif (!isempty(search(argout,"x")) || !isempty(search(argout,"y")) || !isempty(search(argout,"z")))
			xyz = zeros(fType, totalNP, 1)
		end
		if (search(argout,'i') != 0)	intens = zeros(UInt16,  totalNP, 1)	end
		if (search(argout,'t') != 0)	tempo  = zeros(Float64, totalNP, 1)	end
		if (search(argout,'c') != 0)	class  = zeros(Int8,    totalNP, 1)	end
		if (search(argout,'n') != 0)	n_ret  = zeros(Int8,    totalNP, 1)	end
		if (search(argout,'R') != 0 || search(argout,'G') != 0 || search(argout,'B') != 0)
			if (search(argout,'I') != 0)
				RGB = zeros(UInt16,   totalNP, 4)
			else
				RGB = zeros(UInt16,   totalNP, 3)
			end
		end
	end
	#-------------------------------------------------------------------------------------------------

	if (argout == "xyz")
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1]  = pt.X;	xyz[k,2]  = pt.Y;	xyz[k,3]  = pt.Z
		end
	elseif (argout == "xy" || argout == "yx")
		x = 1;	y = 2
		if (argout == "yx") x = 2;	y = 1	end
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,x] = pt.X
			xyz[k,y] = pt.Y
		end
	elseif (argout == 'x')
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1] = pt.X
		end
	elseif (argout == 'y')
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,2] = pt.Y
		end
	elseif (argout == 'z')
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,3] = pt.Z
		end
	elseif (argout == "xyzi")
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1]  = pt.X;	xyz[k,2]  = pt.Y;	xyz[k,3]  = pt.Z
			intens[k] = pt.intensity
		end
	elseif (argout == "xyzit")
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1]  = pt.X;	xyz[k,2]  = pt.Y;	xyz[k,3]  = pt.Z
			intens[k] = pt.intensity
			tempo[k]  = pt.gps_time
		end
	elseif (argout == "xyzic")
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1]  = pt.X;	xyz[k,2]  = pt.Y;	xyz[k,3]  = pt.Z
			intens[k] = pt.intensity
			if (header->point_data_format > 5)
				if (pt.extended_classification != 0) class[k] = pt.extended_classification
				else                                 class[k] = pt.classification
				end
			else
				class[k]  = pt.classification
			end
		end
	elseif (argout == "xyzc")
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1]  = pt.X;	xyz[k,2]  = pt.Y;	xyz[k,3]  = pt.Z
			if (header->point_data_format > 5)
				if (pt.extended_classification != 0) class[k] = pt.extended_classification
				else                                 class[k] = pt.classification
				end
			else
				class[k]  = pt.classification
			end
		end
	elseif (argout == "xyzt")
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[k,1]  = pt.X;	xyz[k,2]  = pt.Y;	xyz[k,3]  = pt.Z
			tempo[k] = pt.gps_time
		end
	elseif (argout == "RGB")
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			RGB[k,1] = pt.rgb.d1;	RGB[k,2] = pt.rgb.d2;	RGB[k,3] = pt.rgb.d3
		end
	elseif (argout == "RGBI")
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			RGB[k,1] = pt.rgb.d1;	RGB[k,2] = pt.rgb.d2;	RGB[k,3] = pt.rgb.d3
			RGB[k,4] = pt.rgb.d4
		end
	elseif (argout != "g")
		# OK, here we have the generic but less efficient code (lots of IFs inside loops)
		# AND THIS IS STILL NOT TAKEN INTO ACOUNT ON OUTPUT. SO BASICALLY IS A NON-WORKING CODE
		for (k = firstPT:lastPT)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			for (n = 1:length(argout))
				if (argout[n] == 'x')
					xyz[k,1] = pt.X
				elseif (argout[n] == 'y')
					xyz[k,2] = pt.Y
				elseif (argout[n] == 'z')
					xyz[k,3] = pt.Z
				elseif (argout[n] == 'i')
					intens[k] = pt.intensity
				elseif (argout[n] == 't')
					tempo[k]  = pt.gps_time
				elseif (argout[n] == 'c')
					if (header->point_data_format > 5)
						if (pt.extended_classification != 0)
							class[k]  = pt.extended_classification
						else
							class[k]  = pt.classification
						end
					else
						class[k]  = pt.classification
					end
				elseif (argout[n] == 'n')
					if (header->point_data_format > 5)
						n_ret = pt.extended_number_of_returns
					else
						n_ret = pt.number_of_returns
					end
				elseif (argout[n] == 'R' || argout[n] == 'G' || argout[n] == 'B')
					RGB[k,1] = pt.rgb.d1
					RGB[k,2] = pt.rgb.d2
					RGB[k,3] = pt.rgb.d3
					if (size(RGB,2) == 4)	RGB[k,4] = pt.rgb.d4	end
				end
			end
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

	if (argout == "xyz" || argout == "xy" || argout == "yx" || argout == "x" || argout == "y" || argout == "z")
		return xyz
	elseif (argout == "xyzi")
		return xyz, intens
	elseif (argout == "xyzt")
		return xyz, tempo
	elseif (argout == "xyzit")
		return xyz, intens, tempo
	elseif (argout == "RGB" || argout == "RGBI")
		return RGB
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
	if (r == 1)
		pop!(z)
	elseif (r == 2)
		pop!(z);	pop!(z)
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

# --------------------------------------------------------------------------------------------
function parse_inputs_las2dat(header, point, reader, opts)
# Check validity of input and in future will parse string options

	# Defaults
	out = zeros(Int8,11)
	outType = 32
	class = 0
	n_inClass = 0
	firstPT = 1
	lastPT  = header.number_of_point_records

	ops = split(opts)
	for (n = 1:length(ops))
		if (ops[n][1:2] == "-F")			# What fields to output and in which order
			i = 1
			for (k = 3:length(ops[n]))
				if (ops[n][k] == 'x')     out[i] = 'x';		i = i + 1
				elseif (ops[n][k] == 'y') out[i] = 'y';		i = i + 1
				elseif (ops[n][k] == 'z') out[i] = 'z';		i = i + 1
				elseif (ops[n][k] == 'i') out[i] = 'i';		i = i + 1
				elseif (ops[n][k] == 'c') out[i] = 'c';		i = i + 1
				elseif (ops[n][k] == 'n') out[i] = 'n';		i = i + 1
				elseif (ops[n][k] == 'R')
					if (header.point_data_format != 2 && header.point_data_format != 3 && header.point_data_format != 5 &&
						header.point_data_format != 7 && header.point_data_format != 8 && header.point_data_format != 10)
						warn("requested 'R' but points do not have RGB. Ignoring it.")
					else
						out[i] = 'R';		i = i + 1
					end
				elseif (ops[n][k] == 'G')
					if (header.point_data_format != 2 && header.point_data_format != 3 && header.point_data_format != 5 &&
						header.point_data_format != 7 && header.point_data_format != 8 && header.point_data_format != 10)
						warn("requested 'G' but points do not have RGB. Ignoring it.")
					else
						out[i] = 'G';		i = i + 1
					end
				elseif (ops[n][k] == 'B')
					if (header.point_data_format != 2 && header.point_data_format != 3 && header.point_data_format != 5 &&
						header.point_data_format != 7 && header.point_data_format != 8 && header.point_data_format != 10)
						warn("requested 'B' but points do not have RGB. Ignoring it.")
					else
						out[i] = 'B';		i = i + 1
					end
				elseif (ops[n][k] == 'I')
					if (header.point_data_format != 8 && header.point_data_format != 10)
						warn("requested 'I' but points do not have RGBI. Ignoring it.")
					else
						out[i] = 'I';		i = i + 1
					end
				elseif (ops[n][k] == 't')
					if (header.point_data_format != 1 && header.point_data_format != 3 &&
						header.point_data_format != 4 && header.point_data_format != 5)
						warn("requested 't' but points do not have gps time. Ignoring it.")
					else
						out[i] = 't';		i = i + 1
					end
				end
			end
		elseif (ops[n][1:2] == "-T")		# The output data type for floats
			if (ops[n][3:end] == "64")
				outType = 64
			end
		elseif (ops[n][1:2] == "-C")		# Restrict by classification
			class = parse(Int,ops[n][3:end])
			# And now check howm many of this class we have
			n_inClass = 0		# Again so no funny plays with more than one -C
			for (n = 1:header.number_of_point_records)
				laszip_read_point(reader)
				pt = unsafe_load(unsafe_load(point))
				if (class == pt.classification) n_inClass = n_inClass + 1		end
			end
			# Here we must rewind the file, no?
			laszip_seek_point(reader, 0)	# Is it this?
		elseif (ops[n][1:2] == "-N")		# Restrict the output to -Nstart/end
			ind = search(ops[n], '/')
			if (ind != 0)
				firstPT = parse(Int,ops[n][3:ind-1])
				lastPT  = parse(Int,ops[n][ind+1:end])
			else
				lastPT  = parse(Int,ops[n][3:end])
			end
			if (firstPT > header.number_of_point_records)	firstPT = 1		end
			if (lastPT  > header.number_of_point_records)	lastPT = header.number_of_point_records		end
		end
	end

	if (class != 0 && n_inClass == 0)
		warn("Requested a class but no points inside that class. Ignoring the class request to avoid error.")
		class = 0
	end

	argout = bytestring(pointer(out))
	return argout, outType, class, firstPT, lastPT
end

