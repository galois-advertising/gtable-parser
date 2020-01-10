import os
import sys
from cmake_setuptools import *
from setuptools import setup

setup(name="gqlparser", 
    version="0.0.1",
    author="solopointer",
    author_email="solopointer1202@gmail.com",
    description="Galois Query Language parser.",
    long_description=open("README.md").read(),
    license="MIT",
    keywords = ("galois", "gql", "parser"),
    url="https://github.com/galois-advertising/",
    packages=['gqlparser'],
    extra_compile_args=['-fPIC -O3 -Wall -std=c++17 -fno-strict-aliasing -Wno-register'],
    ext_modules=[CMakeExtension('pyddl2xml'),CMakeExtension('pygql2xml')],
    cmdclass={'build_ext': CMakeBuildExt},
    zip_safe=False
)