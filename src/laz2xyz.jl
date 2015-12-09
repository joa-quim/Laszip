using Laszip

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
	if (argout != "xyz" && argout != "xyzi" && argout != "xyzt" && argout != "xyzit" && argout != "xyzti")
		error(@sprintf("Laszip: Wrong choice of output arguments.\nThis %s is unsupported\n
			Valid options are: xyz, or xyzi, or xyzit or xyzti", argout))
	end
	if (outType == "")		outType == "Float32"	end
	# -------------------------------------------------------------------------------------------

	laszip_reader = convert(Ptr{Ptr{Void}},pointer([pointer([0])]))
	if (laszip_create(laszip_reader) != 0)
		error("creating laszip reader")
	end

	is_compressed = pointer([Cint(0)]);
	if ((laszip_open_reader(unsafe_load(laszip_reader), fname, is_compressed)) != 0)
		error(@sprintf("opening laszip reader for file %s", fname))
	end

	#is_compressed = unsafe_load(is_compressed)		# If equal 1 file is compressed

	header = pointer([pointer([create_empty_header()])])
	laszip_reader = unsafe_load(laszip_reader)

	if (laszip_get_header_pointer(laszip_reader, header) != 0)		# Get header pointer
		error("getting header pointer from laszip reader")
	end

	# Get a pointer to the points that will be read
	point = pointer([pointer([create_empty_point()])])
	if (laszip_get_point_pointer(laszip_reader, point) != 0)
		error("getting point pointer from laszip reader")
	end

	header = unsafe_load(unsafe_load(header));

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
	#----------------------------------------------------------------------------------

	count = 1;
	if (argout == "xyz")
		while (count <= header.number_of_point_records)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[count,1] = pt.X
			xyz[count,2] = pt.Y
			xyz[count,3] = pt.Z
			count = count + 1;
		end
	elseif (argout == "xyzi")
		while (count <= header.number_of_point_records)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[count,1]  = pt.X
			xyz[count,2]  = pt.Y
			xyz[count,3]  = pt.Z
			intens[count] = pt.intensity
			count = count + 1;
		end
	elseif (argout == "xyzit" || argout == "xyzti")
		while (count <= header.number_of_point_records)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[count,1]  = pt.X
			xyz[count,2]  = pt.Y
			xyz[count,3]  = pt.Z
			intens[count] = pt.intensity
			tempo[count]  = pt.gps_time
			count = count + 1;
		end
	elseif (argout == "xyzt")
		while (count <= header.number_of_point_records)
			laszip_read_point(laszip_reader)
			pt = unsafe_load(unsafe_load(point))
			xyz[count,1]  = pt.X
			xyz[count,2]  = pt.Y
			xyz[count,3]  = pt.Z
			tempo[count]  = pt.gps_time
			count = count + 1;
		end
	end

	if (header.x_scale_factor != 1)
		for (k = 1:header.number_of_point_records)
			xyz[k,1] /= header.x_scale_factor
			xyz[k,2] /= header.y_scale_factor
			xyz[k,3] /= header.z_scale_factor
		end
	end

	# Close the reader
	if (laszip_close_reader(laszip_reader) != 0)
		error("closing laszip reader")
	end
	# Destroy the reader
	if (laszip_destroy(laszip_reader) != 0)
		error("destroying laszip reader")
	end

	if (argout == "xyz")
		return xyz
	elseif (argout == "xyzi")
		return xyz, intens
	elseif (argout == "xyzt")
		return xyz, tempo
	elseif (argout == "xyzit")
		return xyz, intens, tempo
	else
		return xyz, tempo, intens
	end
end