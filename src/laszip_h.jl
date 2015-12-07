# Automatically generated using Clang.jl wrap_c, version 0.0.0

#using Compat

const OBJC_NEW_PROPERTIES = 1

typealias laszip_BOOL Cint
typealias laszip_U8 Cuchar
typealias laszip_U16 UInt16
typealias laszip_U32 UInt32
typealias laszip_U64 Culonglong
typealias laszip_I8 UInt8
typealias laszip_I16 Int16
typealias laszip_I32 Cint
typealias laszip_I64 Clonglong
typealias laszip_CHAR UInt8
typealias laszip_F32 Cfloat
typealias laszip_F64 Cdouble
typealias laszip_POINTER Ptr{Void}

type laszip_geokey
    key_id::UInt16
    tiff_tag_location::UInt16
    count::UInt16
    value_offset::UInt16
end

immutable Array_16_UInt8
    d1::UInt8
    d2::UInt8
    d3::UInt8
    d4::UInt8
    d5::UInt8
    d6::UInt8
    d7::UInt8
    d8::UInt8
    d9::UInt8
    d10::UInt8
    d11::UInt8
    d12::UInt8
    d13::UInt8
    d14::UInt8
    d15::UInt8
    d16::UInt8
end

zero(::Type{Array_16_UInt8}) = begin  # /Users/j/.julia/v0.4/Clang/src/wrap_c.jl, line 266:
        Array_16_UInt8(fill(zero(UInt8),16)...)
    end

immutable Array_32_UInt8
    d1::UInt8
    d2::UInt8
    d3::UInt8
    d4::UInt8
    d5::UInt8
    d6::UInt8
    d7::UInt8
    d8::UInt8
    d9::UInt8
    d10::UInt8
    d11::UInt8
    d12::UInt8
    d13::UInt8
    d14::UInt8
    d15::UInt8
    d16::UInt8
    d17::UInt8
    d18::UInt8
    d19::UInt8
    d20::UInt8
    d21::UInt8
    d22::UInt8
    d23::UInt8
    d24::UInt8
    d25::UInt8
    d26::UInt8
    d27::UInt8
    d28::UInt8
    d29::UInt8
    d30::UInt8
    d31::UInt8
    d32::UInt8
end

zero(::Type{Array_32_UInt8}) = begin  # /Users/j/.julia/v0.4/Clang/src/wrap_c.jl, line 266:
        Array_32_UInt8(fill(zero(UInt8),32)...)
    end

type laszip_vlr
    reserved::UInt16
    user_id::Array_16_UInt8
    record_id::UInt16
    record_length_after_header::UInt16
    description::Array_32_UInt8
    data::Ptr{Cuchar}
end

immutable Array_8_UInt8
    d1::UInt8
    d2::UInt8
    d3::UInt8
    d4::UInt8
    d5::UInt8
    d6::UInt8
    d7::UInt8
    d8::UInt8
end

zero(::Type{Array_8_UInt8}) = begin  # /Users/j/.julia/v0.4/Clang/src/wrap_c.jl, line 266:
        Array_8_UInt8(fill(zero(UInt8),8)...)
    end

immutable Array_5_UInt32
    d1::UInt32
    d2::UInt32
    d3::UInt32
    d4::UInt32
    d5::UInt32
end

zero(::Type{Array_5_UInt32}) = begin  # /Users/j/.julia/v0.4/Clang/src/wrap_c.jl, line 266:
        Array_5_UInt32(fill(zero(UInt32),5)...)
    end

immutable Array_15_Culonglong
    d1::Culonglong
    d2::Culonglong
    d3::Culonglong
    d4::Culonglong
    d5::Culonglong
    d6::Culonglong
    d7::Culonglong
    d8::Culonglong
    d9::Culonglong
    d10::Culonglong
    d11::Culonglong
    d12::Culonglong
    d13::Culonglong
    d14::Culonglong
    d15::Culonglong
end

zero(::Type{Array_15_Culonglong}) = begin  # /Users/j/.julia/v0.4/Clang/src/wrap_c.jl, line 266:
        Array_15_Culonglong(fill(zero(Culonglong),15)...)
    end

type laszip_header
    file_source_ID::UInt16
    global_encoding::UInt16
    project_ID_GUID_data_1::UInt32
    project_ID_GUID_data_2::UInt16
    project_ID_GUID_data_3::UInt16
    project_ID_GUID_data_4::Array_8_UInt8
    version_major::Cuchar
    version_minor::Cuchar
    system_identifier::Array_32_UInt8
    generating_software::Array_32_UInt8
    file_creation_day::UInt16
    file_creation_year::UInt16
    header_size::UInt16
    offset_to_point_data::UInt32
    number_of_variable_length_records::UInt32
    point_data_format::Cuchar
    point_data_record_length::UInt16
    number_of_point_records::UInt32
    number_of_points_by_return::Array_5_UInt32
    x_scale_factor::Cdouble
    y_scale_factor::Cdouble
    z_scale_factor::Cdouble
    x_offset::Cdouble
    y_offset::Cdouble
    z_offset::Cdouble
    max_x::Cdouble
    min_x::Cdouble
    max_y::Cdouble
    min_y::Cdouble
    max_z::Cdouble
    min_z::Cdouble
    start_of_waveform_data_packet_record::Culonglong
    start_of_first_extended_variable_length_record::Culonglong
    number_of_extended_variable_length_records::UInt32
    extended_number_of_point_records::Culonglong
    extended_number_of_points_by_return::Array_15_Culonglong
    user_data_in_header_size::UInt32
    user_data_in_header::Ptr{Cuchar}
    vlrs::Ptr{laszip_vlr}
    user_data_after_header_size::UInt32
    user_data_after_header::Ptr{Cuchar}
end

immutable Array_4_UInt16
    d1::UInt16
    d2::UInt16
    d3::UInt16
    d4::UInt16
end

zero(::Type{Array_4_UInt16}) = begin  # /Users/j/.julia/v0.4/Clang/src/wrap_c.jl, line 266:
        Array_4_UInt16(fill(zero(UInt16),4)...)
    end

immutable Array_29_Cuchar
    d1::Cuchar
    d2::Cuchar
    d3::Cuchar
    d4::Cuchar
    d5::Cuchar
    d6::Cuchar
    d7::Cuchar
    d8::Cuchar
    d9::Cuchar
    d10::Cuchar
    d11::Cuchar
    d12::Cuchar
    d13::Cuchar
    d14::Cuchar
    d15::Cuchar
    d16::Cuchar
    d17::Cuchar
    d18::Cuchar
    d19::Cuchar
    d20::Cuchar
    d21::Cuchar
    d22::Cuchar
    d23::Cuchar
    d24::Cuchar
    d25::Cuchar
    d26::Cuchar
    d27::Cuchar
    d28::Cuchar
    d29::Cuchar
end

zero(::Type{Array_29_Cuchar}) = begin  # /Users/j/.julia/v0.4/Clang/src/wrap_c.jl, line 266:
        Array_29_Cuchar(fill(zero(Cuchar),29)...)
    end

type laszip_point
    X::Cint
    Y::Cint
    Z::Cint
    intensity::UInt16
    return_number::Cuchar
    number_of_returns_of_given_pulse::Cuchar
    scan_direction_flag::Cuchar
    edge_of_flight_line::Cuchar
    classification::Cuchar
    scan_angle_rank::UInt8
    user_data::Cuchar
    point_source_ID::UInt16
    gps_time::Cdouble
    rgb::Array_4_UInt16
    wave_packet::Array_29_Cuchar
    extended_point_type::Cuchar
    extended_scanner_channel::Cuchar
    extended_classification_flags::Cuchar
    extended_classification::Cuchar
    extended_return_number::Cuchar
    extended_number_of_returns_of_given_pulse::Cuchar
    extended_scan_angle::Int16
    num_extra_bytes::Cint
    extra_bytes::Ptr{Cuchar}
end
