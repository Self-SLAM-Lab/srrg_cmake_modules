find_library(DBoW2_LIBRARY DBoW2)
message("DBoW LIBRARY: ${DBoW2_LIBRARY}")


find_path(DBoW2_ROOT_DIR
  NAMES include/DBoW2/DBoW2.h
  HINTS DBoW2
)
message("DBoW ROOT: ${DBoW2_ROOT_DIR}")


find_path(DBoW2_INCLUDE_DIR
  NAMES DBoW2/DBoW2.h
  HINTS ${DBoW2_ROOT_DIR}/include
)

message("DBoW INCLUDE: ${DBoW2_INCLUDE_DIR}")


include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LIBXML2_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(DBoW2  DEFAULT_MSG
                                  DBoW2_LIBRARY DBoW2_INCLUDE_DIR DBoW2_ROOT_DIR)

mark_as_advanced(DBoW2_INCLUDE_DIR DBoW2_LIBRARY DBoW2_ROOT_DIR)

set(DBoW2_DIR ${DBoW2_ROOT_DIR} )
set(DBoW2_LIBRARIES ${DBoW2_LIBRARY} )
set(DBoW2_INCLUDE_DIRS ${DBoW2_INCLUDE_DIR} )
