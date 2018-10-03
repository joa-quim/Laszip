
[![Build Status](https://travis-ci.org/joa-quim/Laszip.jl.svg?branch=master)](https://travis-ci.org/joa-quim/Laszip.jl)

LASZIP.jl
=========

Julia wrapper for the [Laszip](http://www.laszip.org/) library

Install
=======

    Pkg.add("git://github.com/joa-quim/Laszip.jl.git")

For Windows you can download the laszip DLL from [here](http://w3.ualg.pt/~jluis/ftp/laszip_dll_64.zip)
and make sure that the lib *laszip_w64.dll* is found by Julia. For unix, I'm afraid the user will to have
to build the laszip shared library from source.

Using
=====

There are two functions ``las2dat`` and ``dat2las`` to do read/write to the LAZ format. They are still ver basic
but already allow you to read from a laz (laszip compressed *las* file).

    xyz = las2dat("laszfile.laz");

will return a point cloud on the *xyz* Mx3 array. See the function's online help for further options.
