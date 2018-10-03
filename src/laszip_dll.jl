# Julia wrapper for header: /Volumes/BOOTCAMP/programs/compa_libs/thelib/dll/laszip_dll.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0

using Libdl

@static Sys.iswindows() ? (Sys.WORD_SIZE == 64 ? (const suffixed_name = "laszip_w64") : (const suffixed_name = "laszip_w32")) : (const suffixed_name = "laszip")
const thelib = Libdl.find_library(["laszip", suffixed_name])
#const thelib = "V:/laszip/build/bin/laszip_w64"

if isempty(thelib)
    error("could not find thelib library")
end

function laszip_get_version(version_major::Ptr{UInt8},version_minor::Ptr{UInt8},version_revision::Ptr{UInt16},version_build::Ptr{UInt32})
    ccall((:laszip_get_version,thelib),Cint,(Ptr{UInt8},Ptr{UInt8},Ptr{UInt16},Ptr{UInt32}),version_major,version_minor,version_revision,version_build)
end

function laszip_create(pointer::Ptr{Ptr{Cvoid}})
    ccall((:laszip_create,thelib),Cint,(Ptr{Ptr{Cvoid}},),pointer)
end

function laszip_get_error(pointer::Ptr{Cvoid}, error::Ptr{Ptr{UInt8}})
    ccall((:laszip_get_error,thelib),Cint,(Ptr{Cvoid},Ptr{Ptr{UInt8}}),pointer,error)
end
function laszip_get_error(pointer::Ptr{Cvoid}, error::Ptr{String})
    ccall((:laszip_get_error,thelib),Cint,(Ptr{Cvoid},Ptr{Ptr{UInt8}}),pointer,error)
end

function laszip_get_warning(pointer::Ptr{Cvoid},warning::Ptr{Ptr{UInt8}})
    ccall((:laszip_get_warning,thelib),Cint,(Ptr{Cvoid},Ptr{Ptr{UInt8}}),pointer,warning)
end

function laszip_clean(pointer::Ptr{Cvoid})
    ccall((:laszip_clean,thelib),Cint,(Ptr{Cvoid},),pointer)
end

function laszip_destroy(pointer::Ptr{Cvoid})
    ccall((:laszip_destroy,thelib),Cint,(Ptr{Cvoid},),pointer)
end

function laszip_get_header_pointer(pointer::Ptr{Cvoid},header_pointer::Ptr{Ptr{laszip_header}})
    ccall((:laszip_get_header_pointer,thelib),Cint,(Ptr{Cvoid},Ptr{Ptr{laszip_header}}),pointer,header_pointer)
end

function laszip_get_point_pointer(pointer::Ptr{Cvoid},point_pointer::Ptr{Ptr{laszip_point}})
    ccall((:laszip_get_point_pointer,thelib),Cint,(Ptr{Cvoid},Ptr{Ptr{laszip_point}}),pointer,point_pointer)
end

function laszip_get_point_count(pointer::Ptr{Cvoid},count::Ptr{Clonglong})
    ccall((:laszip_get_point_count,thelib),Cint,(Ptr{Cvoid},Ptr{Clonglong}),pointer,count)
end

function laszip_set_header(pointer::Ptr{Cvoid},header::Ptr{laszip_header})
    ccall((:laszip_set_header,thelib),Cint,(Ptr{Cvoid},Ptr{laszip_header}),pointer,header)
end

function laszip_check_for_integer_overflow(pointer::Ptr{Cvoid})
    ccall((:laszip_check_for_integer_overflow,thelib),Cint,(Ptr{Cvoid},),pointer)
end

function laszip_auto_offset(pointer::Ptr{Cvoid})
    ccall((:laszip_auto_offset,thelib),Cint,(Ptr{Cvoid},),pointer)
end

function laszip_set_point(pointer::Ptr{Cvoid},point::Ptr{laszip_point})
    ccall((:laszip_set_point,thelib),Cint,(Ptr{Cvoid},Ptr{laszip_point}),pointer,point)
end

function laszip_set_coordinates(pointer::Ptr{Cvoid},coordinates::Ptr{Cdouble})
    ccall((:laszip_set_coordinates,thelib),Cint,(Ptr{Cvoid},Ptr{Cdouble}),pointer,coordinates)
end

function laszip_get_coordinates(pointer::Ptr{Cvoid},coordinates::Ptr{Cdouble})
    ccall((:laszip_get_coordinates,thelib),Cint,(Ptr{Cvoid},Ptr{Cdouble}),pointer,coordinates)
end

function laszip_set_geokeys(pointer::Ptr{Cvoid},number::UInt32,key_entries::Ptr{laszip_geokey})
    ccall((:laszip_set_geokeys,thelib),Cint,(Ptr{Cvoid},UInt32,Ptr{laszip_geokey}),pointer,number,key_entries)
end

function laszip_set_geodouble_params(pointer::Ptr{Cvoid},number::UInt32,geodouble_params::Ptr{Cdouble})
    ccall((:laszip_set_geodouble_params,thelib),Cint,(Ptr{Cvoid},UInt32,Ptr{Cdouble}),pointer,number,geodouble_params)
end

function laszip_set_geoascii_params(pointer::Ptr{Cvoid},number::UInt32,geoascii_params::Ptr{UInt8})
    ccall((:laszip_set_geoascii_params,thelib),Cint,(Ptr{Cvoid},UInt32,Ptr{UInt8}),pointer,number,geoascii_params)
end

function laszip_add_vlr(pointer::Ptr{Cvoid},vlr::Ptr{laszip_vlr})
    ccall((:laszip_add_vlr,thelib),Cint,(Ptr{Cvoid},Ptr{laszip_vlr}),pointer,vlr)
end

function laszip_open_writer(pointer::Ptr{Cvoid},file_name::Ptr{UInt8},compress::Int)
    ccall((:laszip_open_writer,thelib),Cint,(Ptr{Cvoid},Ptr{UInt8},Cint),pointer,file_name,compress)
end
function laszip_open_writer(pointer::Ptr{Cvoid}, file_name::AbstractString, compress::Int)
    ccall((:laszip_open_writer,thelib),Cint,(Ptr{Cvoid},Ptr{UInt8},Cint),pointer,file_name,compress)
end

function laszip_write_point(pointer::Ptr{Cvoid})
    ccall((:laszip_write_point,thelib),Cint,(Ptr{Cvoid},),pointer)
end

function laszip_close_writer(pointer::Ptr{Cvoid})
    ccall((:laszip_close_writer,thelib),Cint,(Ptr{Cvoid},),pointer)
end

function laszip_open_reader(pointer::Ptr{Cvoid},file_name::Ptr{UInt8},is_compressed::Ptr{Cint})
    ccall((:laszip_open_reader,thelib),Cint,(Ptr{Cvoid},Ptr{UInt8},Ptr{Cint}),pointer,file_name,is_compressed)
end
function laszip_open_reader(pointer::Ptr{Cvoid},file_name::AbstractString, is_compressed::Ptr{Cint})
    ccall((:laszip_open_reader,thelib),Cint,(Ptr{Cvoid},Ptr{UInt8},Ptr{Cint}),pointer,file_name,is_compressed)
end

function laszip_seek_point(pointer::Ptr{Cvoid},index::Clonglong)
    ccall((:laszip_seek_point,thelib),Cint,(Ptr{Cvoid},Clonglong),pointer,index)
end

function laszip_read_point(pointer::Ptr{Cvoid})
    ccall((:laszip_read_point,thelib),Cint,(Ptr{Cvoid},),pointer)
end

function laszip_close_reader(pointer::Ptr{Cvoid})
    ccall((:laszip_close_reader,thelib),Cint,(Ptr{Cvoid},),pointer)
end

function create_empty_header()
    ccall((:create_empty_header,thelib),laszip_header,())
end
function create_empty_point()
    ccall((:create_empty_point,thelib),laszip_point,())
end
function create_empty_vlr()
    ccall((:create_empty_vlr,thelib),laszip_vlr,())
end
