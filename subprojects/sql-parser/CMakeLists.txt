cmake_minimum_required(VERSION 3.22)

project(sql-parser)

set(CMAKE_CXX_STANDARD 14)

aux_source_directory(. SOURCE_DIR)

add_executable(sql-parser ${SOURCE_DIR})
