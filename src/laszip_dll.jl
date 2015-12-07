# Julia wrapper for header: /Volumes/BOOTCAMP/programs/compa_libs/LASzip/dll/laszip_dll.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0

WORD_SIZE == 64 ? suffixed_name = "laszip_w64" : suffixed_name = "laszip_w32"
const laszip = Libdl.find_library(["laszip", suffixed_name])
if isempty(laszip)
    error("could not find Laszip library")
end


function laszip_get_version(version_major::Ptr{UInt8},version_minor::Ptr{UInt8},version_revision::Ptr{UInt16},version_build::Ptr{UInt32})
    ccall((:laszip_get_version,laszip),Cint,(Ptr{UInt8},Ptr{UInt8},Ptr{UInt16},Ptr{UInt32}),version_major,version_minor,version_revision,version_build)
end

function laszip_create(pointer::Ptr{Ptr{Void}})
    ccall((:laszip_create,laszip),Cint,(Ptr{Ptr{Void}},),pointer)
end

function laszip_get_error(pointer::Ptr{Void},error::Ptr{Ptr{UInt8}})
    ccall((:laszip_get_error,laszip),Cint,(Ptr{Void},Ptr{Ptr{UInt8}}),pointer,error)
end

function laszip_get_warning(pointer::Ptr{Void},warning::Ptr{Ptr{UInt8}})
    ccall((:laszip_get_warning,laszip),Cint,(Ptr{Void},Ptr{Ptr{UInt8}}),pointer,warning)
end

function laszip_clean(pointer::Ptr{Void})
    ccall((:laszip_clean,laszip),Cint,(Ptr{Void},),pointer)
end

function laszip_destroy(pointer::Ptr{Void})
    ccall((:laszip_destroy,laszip),Cint,(Ptr{Void},),pointer)
end

function laszip_get_header_pointer(pointer::Ptr{Void},header_pointer::Ptr{Ptr{laszip_header}})
    ccall((:laszip_get_header_pointer,laszip),Cint,(Ptr{Void},Ptr{Ptr{laszip_header}}),pointer,header_pointer)
end

function laszip_get_point_pointer(pointer::Ptr{Void},point_pointer::Ptr{Ptr{laszip_point}})
    ccall((:laszip_get_point_pointer,laszip),Cint,(Ptr{Void},Ptr{Ptr{laszip_point}}),pointer,point_pointer)
end

function laszip_get_point_count(pointer::Ptr{Void},count::Ptr{Clonglong})
    ccall((:laszip_get_point_count,laszip),Cint,(Ptr{Void},Ptr{Clonglong}),pointer,count)
end

function laszip_set_header(pointer::Ptr{Void},header::Ptr{laszip_header})
    ccall((:laszip_set_header,laszip),Cint,(Ptr{Void},Ptr{laszip_header}),pointer,header)
end

function laszip_check_for_integer_overflow(pointer::Ptr{Void})
    ccall((:laszip_check_for_integer_overflow,laszip),Cint,(Ptr{Void},),pointer)
end

function laszip_auto_offset(pointer::Ptr{Void})
    ccall((:laszip_auto_offset,laszip),Cint,(Ptr{Void},),pointer)
end

function laszip_set_point(pointer::Ptr{Void},point::Ptr{laszip_point})
    ccall((:laszip_set_point,laszip),Cint,(Ptr{Void},Ptr{laszip_point}),pointer,point)
end

function laszip_set_coordinates(pointer::Ptr{Void},coordinates::Ptr{Cdouble})
    ccall((:laszip_set_coordinates,laszip),Cint,(Ptr{Void},Ptr{Cdouble}),pointer,coordinates)
end

function laszip_get_coordinates(pointer::Ptr{Void},coordinates::Ptr{Cdouble})
    ccall((:laszip_get_coordinates,laszip),Cint,(Ptr{Void},Ptr{Cdouble}),pointer,coordinates)
end

function laszip_set_geokeys(pointer::Ptr{Void},number::UInt32,key_entries::Ptr{laszip_geokey})
    ccall((:laszip_set_geokeys,laszip),Cint,(Ptr{Void},UInt32,Ptr{laszip_geokey}),pointer,number,key_entries)
end

function laszip_set_geodouble_params(pointer::Ptr{Void},number::UInt32,geodouble_params::Ptr{Cdouble})
    ccall((:laszip_set_geodouble_params,laszip),Cint,(Ptr{Void},UInt32,Ptr{Cdouble}),pointer,number,geodouble_params)
end

function laszip_set_geoascii_params(pointer::Ptr{Void},number::UInt32,geoascii_params::Ptr{UInt8})
    ccall((:laszip_set_geoascii_params,laszip),Cint,(Ptr{Void},UInt32,Ptr{UInt8}),pointer,number,geoascii_params)
end

function laszip_add_vlr(pointer::Ptr{Void},vlr::Ptr{laszip_vlr})
    ccall((:laszip_add_vlr,laszip),Cint,(Ptr{Void},Ptr{laszip_vlr}),pointer,vlr)
end

function laszip_open_writer(pointer::Ptr{Void},file_name::Ptr{UInt8},compress::Cint)
    ccall((:laszip_open_writer,laszip),Cint,(Ptr{Void},Ptr{UInt8},Cint),pointer,file_name,compress)
end

function laszip_write_point(pointer::Ptr{Void})
    ccall((:laszip_write_point,laszip),Cint,(Ptr{Void},),pointer)
end

function laszip_close_writer(pointer::Ptr{Void})
    ccall((:laszip_close_writer,laszip),Cint,(Ptr{Void},),pointer)
end

function laszip_open_reader(pointer::Ptr{Void},file_name::Ptr{UInt8},is_compressed::Ptr{Cint})
    ccall((:laszip_open_reader,laszip),Cint,(Ptr{Void},Ptr{UInt8},Ptr{Cint}),pointer,file_name,is_compressed)
end
function laszip_open_reader(pointer::Ptr{Void},file_name::ASCIIString,is_compressed::Ptr{Cint})
    ccall((:laszip_open_reader,laszip),Cint,(Ptr{Void},Ptr{UInt8},Ptr{Cint}),pointer,file_name,is_compressed)
end

function laszip_seek_point(pointer::Ptr{Void},index::Clonglong)
    ccall((:laszip_seek_point,laszip),Cint,(Ptr{Void},Clonglong),pointer,index)
end

function laszip_read_point(pointer::Ptr{Void})
    ccall((:laszip_read_point,laszip),Cint,(Ptr{Void},),pointer)
end

function laszip_close_reader(pointer::Ptr{Void})
    ccall((:laszip_close_reader,laszip),Cint,(Ptr{Void},),pointer)
end

function create_empty_header()
    ccall((:create_empty_header,laszip),laszip_header,())
end
function create_empty_point()
    ccall((:create_empty_point,laszip),laszip_point,())
end
function create_empty_vlr()
    ccall((:create_empty_vlr,laszip),laszip_vlr,())
end
