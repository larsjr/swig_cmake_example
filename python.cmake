# SWIG code
FIND_PACKAGE(SWIG REQUIRED)
include(UseSWIG)

FIND_PACKAGE(Python3 COMPONENTS Interpreter Development)
INCLUDE_DIRECTORIES(${Python3_INCLUDE_DIRS})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Remove python debug libraries if they are found
list(FIND Python3_LIBRARIES "debug" debug_index)
if(${debug_index} GREATER -1)
    message("Python3_LIBRARIES: ${Python3_LIBRARIES}")
    math(EXPR debug_lib_file_index "${debug_index}+1")
    list(REMOVE_AT Python3_LIBRARIES ${debug_index} ${debug_lib_file_index})
    message("After remove: ${Python3_LIBRARIES}")
endif()

list(FIND Python3_LIBRARIES "optimized" optimized_index)
if(${optimized_index} GREATER -1)
    list(REMOVE_AT Python3_LIBRARIES ${optimized_index})
endif()

set(CMAKE_SWIG_FLAGS "")


# Build swig module
SET_SOURCE_FILES_PROPERTIES(python/example.i PROPERTIES CPLUSPLUS ON)
SET_SOURCE_FILES_PROPERTIES(python/example.i SWIG_FLAGS "-includeall")
SWIG_ADD_LIBRARY(example
    TYPE SHARED
    LANGUAGE python
    OUTPUT_DIR ${CMAKE_BINARY_DIR}/python/${PROJECT_NAME}/Example
    SOURCES python/example.i)
SWIG_LINK_LIBRARIES(example ${Python3_LIBRARIES} cppex)


# Python packaging 
configure_file(cmake/__init__.py.in python/${PROJECT_NAME}/__init__.py COPYONLY)
configure_file(cmake/__init__.py.in python/${PROJECT_NAME}/Example/__init__.py COPYONLY)

# Generate setup.py
file(REMOVE ${CMAKE_BINARY_DIR}/python/setup.py)
add_custom_command(OUTPUT setup.py dist ${PROJECT_NAME}.egg-info
    COMMAND ${CMAKE_COMMAND} -E echo "from setuptools import find_packages, setup" > setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "from setuptools.dist import Distribution" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "class BinaryDistribution(Distribution):" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  def is_pure(self):" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "    return False" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  def has_ext_modules(self):" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "    return True" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "from setuptools.command.install import install" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "class InstallPlatlib(install):" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "    def finalize_options(self):" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "        install.finalize_options(self)" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "        self.install_lib=self.install_platlib" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "setup(" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  name='${PROJECT_NAME}'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  version='${PROJECT_VERSION}'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  author='ICGI'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  distclass=BinaryDistribution," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  cmdclass={'install': InstallPlatlib}," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  packages=find_packages()," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  package_data={" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  '${PROJECT_NAME}':[$<$<NOT:$<PLATFORM_ID:Windows>>:'.libs/*'>]," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  '${PROJECT_NAME}.Example':['$<TARGET_FILE_NAME:example>']," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  }," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  include_package_data=True," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  classifiers=[" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'Development Status :: 5 - Production/Stable'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'Intended Audience :: Developers'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'License :: OSI Approved :: Apache Software License'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'Operating System :: POSIX :: Linux'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'Operating System :: Microsoft :: Windows'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'Programming Language :: Python'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'Programming Language :: C++'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'Topic :: Scientific/Engineering'," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  'Topic :: Software Development :: Libraries :: Python Modules'" >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo "  ]," >> setup.py
    COMMAND ${CMAKE_COMMAND} -E echo ")" >> setup.py
    COMMENT "Generate setup.py at build time (to use generator expression)"
    WORKING_DIRECTORY python
    VERBATIM)

# Copy swig binary files to correct location
add_custom_target(bdist ALL
    DEPENDS setup.py
    COMMAND ${CMAKE_COMMAND} -E remove_directory dist
    COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_NAME}/.libs
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:example> ${PROJECT_NAME}/example
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:cppex> ${PROJECT_NAME}/.libs
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_LINKER_FILE:cppex> ${PROJECT_NAME}/.libs
    COMMAND ${PYTHON_EXECUTABLE} setup.py bdist_wheel
    WORKING_DIRECTORY python)
