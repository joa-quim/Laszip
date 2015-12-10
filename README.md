# Laszip

[![Build Status](https://travis-ci.org/joa-quim/Laszip.jl.svg?branch=master)](https://travis-ci.org/joa-quim/Laszip.jl)

LASZIP.jl
=========

Julia wrapper for the [Laszip](http://www.laszip.org/) library

Install
=======

    (Pkg.init()		# If you haven't done it yet)
    Pkg.clone("git://github.com/joa-quim/Laszip.jl.git")

Note: for the time being this only works for windows because I had to use a custom build of the laszip DLL.
You can download it from [here](http://w3.ualg.pt/~jluis/ftp/laszip_dll_64.zip) and make sure that the lib
*laszip_w64.dll* is found by Julia.


Using
=====

There are tho functions ``las2xyz`` and ``xyz2las`` to do read/write to the LAZ format. They are still ver basic
but already allow you to read from a laz (laszip compressed of a las file).

    xyz = las2xyz("laszfile.laz");

will return a point cloud on the *xyz* Mx3 array. See the function's online help for further options.