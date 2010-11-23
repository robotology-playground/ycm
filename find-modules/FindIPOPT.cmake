# Created:
# IPOPT_INCLUDE_DIRS - Directories to include to use IPOPT
# IPOPT_LIBRARIES    - Default library to link against to use IPOPT
# IPOPT_LINK_FLAGS   - Flags to be added to linker's options
# IPOPT_FOUND        - If false, don't try to use IPOPT

SET(IPOPT_DIR $ENV{IPOPT_DIR} CACHE PATH "Path to IPOPT build directory")
SET(IPOPT_INCLUDE_DIRS ${IPOPT_DIR}/include/coin)

IF(WIN32)

   FIND_LIBRARY(IPOPT_LIBRARIES_RELEASE libipopt  ${IPOPT_DIR}/lib 
                                                  ${IPOPT_DIR}/lib/coin
                                                  NO_DEFAULT_PATH)
   FIND_LIBRARY(IPOPT_LIBRARIES_DEBUG   libipoptD ${IPOPT_DIR}/lib
                                                  ${IPOPT_DIR}/lib/coin
                                                  NO_DEFAULT_PATH)

   IF(IPOPT_LIBRARIES_RELEASE AND IPOPT_LIBRARIES_DEBUG)
      SET(IPOPT_LIBRARIES optimized ${IPOPT_LIBRARIES_RELEASE} debug ${IPOPT_LIBRARIES_DEBUG})
   ELSE(IPOPT_LIBRARIES_RELEASE AND IPOPT_LIBRARIES_DEBUG)
      IF(IPOPT_LIBRARIES_RELEASE)
         SET(IPOPT_LIBRARIES ${IPOPT_LIBRARIES_RELEASE})
      ELSE(IPOPT_LIBRARIES_RELEASE)
         IF(IPOPT_LIBRARIES_DEBUG)
            SET(IPOPT_LIBRARIES ${IPOPT_LIBRARIES_DEBUG})
         ENDIF(IPOPT_LIBRARIES_DEBUG)
      ENDIF(IPOPT_LIBRARIES_RELEASE)
   ENDIF(IPOPT_LIBRARIES_RELEASE AND IPOPT_LIBRARIES_DEBUG)

   SET(IPOPT_LIBRARIES_RELEASE "")
   SET(IPOPT_LIBRARIES_DEBUG "")

    IF(MSVC)
        SET(IPOPT_LINK_FLAGS "/NODEFAULTLIB:libcmt.lib;libcmtd.lib")
    ELSE(MSVC)
        SET(IPOPT_LINK_FLAGS "")
    ENDIF(MSVC)
    
ELSE(WIN32)

   FIND_PACKAGE(PkgConfig)
   IF(PKG_CONFIG_FOUND)
     PKG_CHECK_MODULES(IPOPT ipopt)
   ENDIF(PKG_CONFIG_FOUND)

   IF(NOT IPOPT_FOUND)
      FIND_LIBRARY(IPOPT_LIBRARIES ipopt ${IPOPT_DIR}/lib
                                         ${IPOPT_DIR}/lib/coin)
      IF(IPOPT_LIBRARIES)
         FIND_FILE(IPOPT_DEP_FILE ipopt_addlibs_cpp.txt ${IPOPT_DIR}/share/doc/coin/Ipopt
                                                        ${IPOPT_DIR}/share/coin/doc/Ipopt
                                                        NO_DEFAULT_PATH)
         IF(IPOPT_DEP_FILE)
            # parse the file and acquire the dependences
            FILE(READ ${IPOPT_DEP_FILE} IPOPT_DEP)
            STRING(REGEX REPLACE "-[^l][^ ]* " "" IPOPT_DEP ${IPOPT_DEP})
            STRING(REPLACE "-l"                "" IPOPT_DEP ${IPOPT_DEP})
            STRING(REPLACE "\n"                "" IPOPT_DEP ${IPOPT_DEP})
            STRING(REPLACE "ipopt"             "" IPOPT_DEP ${IPOPT_DEP})	# remove any possible auto-dependence
            SEPARATE_ARGUMENTS(IPOPT_DEP)

            # use the find_library command in order to prepare rpath correctly 
	    FOREACH(LIB ${IPOPT_DEP})
	       FIND_LIBRARY(${LIB}_LIB ${LIB} ${IPOPT_DIR}/lib
                                              ${IPOPT_DIR}/lib/coin
	     		   		      ${IPOPT_DIR}/lib/coin/ThirdParty
	     				      NO_DEFAULT_PATH)
               IF(${LIB}_LIB)
                  SET(IPOPT_LIBRARIES ${IPOPT_LIBRARIES} ${${LIB}_LIB})
               ELSE(${LIB}_LIB)
                  SET(IPOPT_LIBRARIES ${IPOPT_LIBRARIES} ${LIB})
	       ENDIF(${LIB}_LIB)
	    ENDFOREACH(LIB)
         ELSE(IPOPT_DEP_FILE)
            SET(IPOPT_INCLUDE_DIRS /usr/include/coin)
         ENDIF(IPOPT_DEP_FILE)
      ENDIF(IPOPT_LIBRARIES)
   ENDIF(NOT IPOPT_FOUND)
   
   SET(IPOPT_LINK_FLAGS "")

ENDIF(WIN32)

IF(IPOPT_LIBRARIES)
   SET(IPOPT_FOUND TRUE)
ELSE(IPOPT_LIBRARIES)
   SET(IPOPT_FOUND FALSE)
   SET(IPOPT_INCLUDE_DIRS "")
   SET(IPOPT_LIBRARIES "")
   SET(IPOPT_LINK_FLAGS "")
ENDIF(IPOPT_LIBRARIES)


