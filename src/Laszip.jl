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
	xyz2laz, laz2xyz, msgerror, las2dat, dat2las

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

end # module
