module Laszip

export
	create_empty_header, create_empty_point, create_empty_vlr,
	laszip_get_point_pointer, laszip_get_header_pointer,
	laszip_get_version,
	laszip_create,
	laszip_get_error,
	laszip_get_warning,
	laszip_clean,
	laszip_destroy,
	laszip_get_header_pointer,
	laszip_get_point_pointer,
	laszip_get_point_count,
	laszip_set_header,
	laszip_check_for_integer_overflow,
	laszip_auto_offset,
	laszip_set_point,
	laszip_set_coordinates,
	laszip_get_coordinates,
	laszip_set_geokeys,
	laszip_set_geodouble_params,
	laszip_set_geoascii_params,
	laszip_add_vlr,
	laszip_open_writer,
	laszip_write_point,
	laszip_close_writer,
	laszip_open_reader,
	laszip_seek_point,
	laszip_read_point,
	laszip_close_reader,
# Non C-wrapper functions
	xyz2laz, laz2xyz, msgerror, las2dat, dat2las, create_header, create_point

include("laszip_h.jl")
include("laszip_dll.jl")
include("laz2xyz.jl")
include("xyz2laz.jl")

"""
	Prints an laszip error message and error out

	msgerror(lzobj::Ptr{Void}, extramsg::AbstractString="")

	Where:
		"lzobj" is a pointer to laszip_readert|writer created by unsafe_load(laszip_create(arg))
		"extramsg" is an optional extra message to be printed before the laszip error message.
"""

function msgerror(lzobj::Ptr{Void}, extramsg::AbstractString="")
	pStr = pointer([pointer(lpad("",128,"        "))])		# Create a 1024 bytes string and get its pointer
	laszip_get_error(lzobj, pStr)
	Str = bytestring(unsafe_load(pStr))
	if (isempty(extramsg))
		error(Str)
	else
		error(extramsg * "\n\t" * Str)
	end
end
function msgerror(lzobj::Ptr{Ptr{Void}}, extramsg::AbstractString="")
	lzobj = unsafe_load(lzobj)
	msgerror(lzobj, extramsg)
end

# ---------------------------------------------------------------------------------------------
function create_header(project_ID_GUID_data_4="", system_identifier="", generating_software="")
# Initialize an empty (or almost) header type
	if (isempty(project_ID_GUID_data_4))
		project_ID_GUID_data_4 = Laszip.Array_8_UInt8(fill(Base.zero(UInt8),8)...)
	end
	if (isempty(system_identifier))
		system_identifier = Laszip.Array_32_UInt8(fill(Base.zero(UInt8),32)...)
	end
	if (isempty(generating_software))
		generating_software = Laszip.Array_32_UInt8(fill(Base.zero(UInt8),32)...)
	end
	number_of_points_by_return = Laszip.Array_5_UInt32(fill(Base.zero(UInt32),5)...)
	extended_number_of_points_by_return = Laszip.Array_15_Culonglong(fill(Base.zero(Culonglong),15)...)
	user_data_in_header = pointer("")
	vlrs = pointer([laszip_vlr])
	user_data_after_header = pointer("")
	Laszip.laszip_header(0, 0, 0, 0, 0, project_ID_GUID_data_4, '1', '2', system_identifier, generating_software,
	                     0, 0, 0, 0, 0, '0', 0, 0, number_of_points_by_return, 1., 1., 1., 0., 0., 0.,
	                     0., 0., 0., 0., 0., 0., 0, 0, 0, 0, extended_number_of_points_by_return,
	                     0, user_data_in_header, vlrs, 0, user_data_after_header)
end


# ---------------------------------------------------------------------------------------------
function create_point()
# Initialize an empty point type
	rgb = Laszip.Array_4_UInt16(fill(Base.zero(UInt16),4)...)
	dummy = Laszip.Array_7_Cuchar(fill(Base.zero(Cuchar),7)...)
	wave_packet = Laszip.Array_29_Cuchar(fill(Base.zero(Cuchar),29)...)
	laszip_point(0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, '0', 0, 0, '0', '0', '0', '0', '0', '0',
	             dummy, 0., rgb, wave_packet, 0, pointer(""))
end

end # module
