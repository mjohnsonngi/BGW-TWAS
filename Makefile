#Makefile

# Supported platforms
#       Unix / Linux               	LNX
#       Mac                        	MAC
# Compilation options
#       link to LAPACK              WITH_LAPACK
#       32-bit binary        		FORCE_32BIT

# Set this variable to either LNX or MAC
SYS = LNX

# Leave blank after "=" to disable; put "= 1" to enable
# Disable WITH_LAPACK option can slow computation speed significantly and is not recommended
# Disable WITH_ARPACK option only disable -apprx option in the software
WITH_LAPACK = 1
FORCE_32BIT = 
DIST_NAME = Estep_mcmc

# --------------------------------------------------------------------
# Edit below this line with caution
# --------------------------------------------------------------------

BIN_DIR  = ./bin

SRC_DIR  = ./src

HDR = 

OUTPUT = $(BIN_DIR)/Estep_mcmc

SOURCES = $(SRC_DIR)/main.cpp

CPP = g++

## Will need the bfGWAS_SS/libStateGen/MemoryAllocators.h and bfGWAS_SS/libStateGen/MemoryAllocators.cpp from "https://github.com/yjingj/bfGWAS_SS.git"; the ones from original libStatGen.git will cause error
## C++ libraries used in this tool: zlib, gsl, eigen3, lapack, atlas, blas; Please add -I[path to libraries] accordingly

CPPFLAGS = -ggdb -Wall -O3 -I/usr/lib/x86_64-linux-gnu/ -I/usr/lib/x86_64-linux-gnu/openblas-pthread/ -I./libStatGen/include/ -I/usr/local/lib/gsl/include/ -I/usr/local/lib/zlib/include -I/usr/local/lib/  -D__ZLIB_AVAILABLE__ -D_FILE_OFFSET_BITS=64 -D__STDC_LIMIT_MACROS #-pg


## Include correct libraries of gsl, blas, lapack, atlas, libStatGen
LIBS = -lgsl -lgslcblas -pthread -lz -lm ./libStatGen/libStatGen.a

# Detailed library paths, D for dynamic and S for static
LIBS_LNX_D_LAPACK = -llapack
LIBS_MAC_D_LAPACK = -framework Veclib
LIBS_LNX_S_LAPACK = /usr/lib/x86_64-linux-gnu/liblapack.so /usr/lib/x86_64-linux-gnu/libatlas.so.3 /usr/lib/x86_64-linux-gnu/libblas.so -lgfortran -Wl,--allow-multiple-definition

#LIBS_LNX_S_LAPACK = /usr/lib64/liblapacke.so -lgfortran /usr/lib64/libsatlas.so.3 /usr/lib64/libblas.so -Wl,--allow-multiple-definition
#LIBS_LNX_S_LAPACK = /usr/lib/lapack/liblapack.a -lgfortran  /usr/lib/atlas-base/libatlas.a /usr/lib/libblas/libblas.a -Wl,--allow-multiple-definition 

# Options

SOURCES += $(SRC_DIR)/param.cpp $(SRC_DIR)/bfgwas.cpp $(SRC_DIR)/io.cpp $(SRC_DIR)/lm.cpp  $(SRC_DIR)/bvsrm.cpp $(SRC_DIR)/mathfunc.cpp $(SRC_DIR)/gzstream.cpp $(SRC_DIR)/ReadVCF.cpp $(SRC_DIR)/compress.cpp $(SRC_DIR)/calcSS.cpp
HDR += $(SRC_DIR)/param.h $(SRC_DIR)/bfgwas.h $(SRC_DIR)/io.h $(SRC_DIR)/lm.h $(SRC_DIR)/bvsrm.h $(SRC_DIR)/mathfunc.h $(SRC_DIR)/gzstream.h $(SRC_DIR)/ReadVCF.h $(SRC_DIR)/compress.h $(SRC_DIR)/calcSS.h


ifdef WITH_LAPACK
  OBJS += $(SRC_DIR)/lapack.o
  CPPFLAGS += -DWITH_LAPACK

ifeq ($(SYS), MAC)
  LIBS += $(LIBS_MAC_D_LAPACK)
else
  LIBS += $(LIBS_LNX_S_LAPACK)
endif

  SOURCES += $(SRC_DIR)/lapack.cpp
  HDR += $(SRC_DIR)/lapack.h
endif

ifdef FORCE_32BIT
  CPPFLAGS += -m32
else
  CPPFLAGS += -m64
endif


# all
OBJS = $(SOURCES:.cpp=.o)

all: $(OUTPUT)

$(OUTPUT): $(OBJS)
	$(CPP) $(CPPFLAGS) $(OBJS) $(LIBS) -o $(OUTPUT)

$(OBJS) : $(HDR)

.cpp.o: 
	$(CPP) $(CPPFLAGS) $(HEADERS) -c $*.cpp -o $*.o
.SUFFIXES : .cpp .c .o $(SUFFIXES)


clean:
	rm -rf ${SRC_DIR}/*.o ${SRC_DIR}/*~ *~ ${SRC_DIR}/*_float.* $(OUTPUT)

DIST_COMMON = COPYING.txt README.txt Makefile
DIST_SUBDIRS = src doc example bin

tar:
	mkdir -p ./$(DIST_NAME)
	cp $(DIST_COMMON) ./$(DIST_NAME)/
	cp -r $(DIST_SUBDIRS) ./$(DIST_NAME)/
	tar cvzf $(DIST_NAME).tar.gz ./$(DIST_NAME)/
	rm -r ./$(DIST_NAME)
