# makefile
#
#
#  Directives :
#
#    

SHELL=/bin/bash
FC=gfortran
FCUNI=gfortran
MPIF90=/home/joe/Software/openmpi/bin/mpif90
#LIB=-L/usr/local/lapack -llapack -lrefblas
LIB=
INC=-I/home/joe/Software/openmpi/include/
#OPT=-O3
OPT=-O0 -fcheck=all -Wall
WFLAGS= 
SRCDIR=../../../../src/

# specify the directory main directory for this experiment
DIR=$(shell pwd | rev | cut -d "/" -f2- | rev )
INIDIR=${DIR}/



# ---------------------------------------------------------------------- #
#                           ~/src/common/                                #
# ---------------------------------------------------------------------- #

# Modules
ModelPrecision.o :
	${FC} ${OPT} -c ${SRCDIR}common/ModelPrecision.f90 -o $@

ModelFlags.o :
	${FC} ${OPT} -c ${SRCDIR}common/ModelFlags.f90 -o $@

LinkedListClass.o :
	${FC} ${OPT} -c ${SRCDIR}common/LinkedListClass.f90 -o $@

KeyRingClass.o : CommonRoutines.o
	${FC} ${OPT} -c ${SRCDIR}common/KeyRingClass.f90 -o $@

HashTableClass.o : ConstantsDictionary.o LinkedListClass.o
	${FC} ${OPT} -c ${SRCDIR}common/HashTableClass.f90 -o $@

ConstantsDictionary.o : ModelPrecision.o
	${FC} ${OPT} -c ${SRCDIR}common/ConstantsDictionary.f90 -o $@

CommonRoutines.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o
	${FC} ${OPT} -c ${SRCDIR}common/CommonRoutines.f90 -o $@

RunParamsClass.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o
	${FC} ${OPT} -c ${SRCDIR}common/RunParamsClass.f90 -o $@

Timing.o : ModelPrecision.o ConstantsDictionary.o CommonRoutines.o
	${FC} ${OPT} -c ${SRCDIR}common/Timing.f90 -o $@

# Test programs

   
# ---------------------------------------------------------------------- #
#                           ~/src/interp/                                #
# ---------------------------------------------------------------------- #

# Modules
Chebyshev.o : ModelPrecision.o ConstantsDictionary.o
	${FC} ${OPT} -c ${SRCDIR}interp/Chebyshev.f90 -o $@

Legendre.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o
	${FC} ${OPT} -c ${SRCDIR}interp/Legendre.f90 -o $@

Lagrange_1D_Class.o : ModelPrecision.o ConstantsDictionary.o CommonRoutines.o
	${FC} ${OPT} -c ${SRCDIR}interp/Lagrange_1D_Class.f90 -o $@

Lagrange_2D_Class.o : ModelPrecision.o ConstantsDictionary.o CommonRoutines.o Lagrange_1D_Class.o
	${FC} ${OPT} -c ${SRCDIR}interp/Lagrange_2D_Class.f90 -o $@
	
Lagrange_3D_Class.o : ModelPrecision.o ConstantsDictionary.o CommonRoutines.o Lagrange_1D_Class.o
	${FC} ${OPT} -c ${SRCDIR}interp/Lagrange_3D_Class.f90 -o $@

# Test Programs

# ---------------------------------------------------------------------- #
#                            ~/src/nodal/                                #
# ---------------------------------------------------------------------- #

# Modules
NodalStorage_1D_Class.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o Legendre.o \
                          Lagrange_1D_Class.o
	${FC} ${OPT} -c ${SRCDIR}nodal/NodalStorage_1D_Class.f90 -o $@

NodalStorage_2D_Class.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o Legendre.o \
                          Lagrange_1D_Class.o Lagrange_2D_Class.o
	${FC} ${OPT} -c ${SRCDIR}nodal/NodalStorage_2D_Class.f90 -o $@

NodalStorage_3D_Class.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o Legendre.o \
                          Lagrange_1D_Class.o Lagrange_3D_Class.o
	${FC} ${OPT} -c ${SRCDIR}nodal/NodalStorage_3D_Class.f90 -o $@

# Test Programs

# ---------------------------------------------------------------------- #
#                          ~/src/filters/                                #
# ---------------------------------------------------------------------- #

# Modules
ModalCutoffFilter1D_Class.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o \
                                  Legendre.o Lagrange_1D_Class.o NodalStorage_1D_Class.o
	${FC} ${OPT} -c ${SRCDIR}filters/ModalCutoffFilter1D_Class.f90 -o $@

ModalCutoffFilter2D_Class.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o \
                          Legendre.o Lagrange_2D_Class.o NodalStorage_2D_Class.o
	${FC} ${OPT} -c ${SRCDIR}filters/ModalCutoffFilter2D_Class.f90 -o $@

RollOffFilter1D_Class.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o \
                          Legendre.o Lagrange_1D_Class.o NodalStorage_1D_Class.o
	${FC} ${OPT} -c ${SRCDIR}filters/RollOffFilter1D_Class.f90 -o $@

RollOffFilter2D_Class.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o \
                          Legendre.o Lagrange_2D_Class.o NodalStorage_2D_Class.o
	${FC} ${OPT} -c ${SRCDIR}filters/RollOffFilter2D_Class.f90 -o $@

RollOffFilter3D_Class.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o \
                          Legendre.o Lagrange_3D_Class.o NodalStorage_3D_Class.o
	${FC} ${OPT} -c ${SRCDIR}filters/RollOffFilter3D_Class.f90 -o $@

# ---------------------------------------------------------------------- #
#                            ~/src/dgsem/                                #
# ---------------------------------------------------------------------- #

# Modules
DGSEMSolutionStorageClass_1D.o : ModelPrecision.o ConstantsDictionary.o NodalStorage_1D_Class.o
	${FC} ${OPT} -c ${SRCDIR}dgsem/DGSEMSolutionStorageClass_1D.f90 -o $@

DGSEMSolutionStorageClass_2D.o : ModelPrecision.o ConstantsDictionary.o NodalStorage_2D_Class.o
	${FC} ${OPT} -c ${SRCDIR}dgsem/DGSEMSolutionStorageClass_2D.f90 -o $@
	
DGSEMSolutionStorageClass_3D.o : ModelPrecision.o ConstantsDictionary.o NodalStorage_3D_Class.o
	${FC} ${OPT} -c ${SRCDIR}dgsem/DGSEMSolutionStorageClass_3D.f90 -o $@

# ---------------------------------------------------------------------- #
#                             ~/src/mpi/                                 #
# ---------------------------------------------------------------------- #

# Modules
BoundaryCommunicator2D_Class.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o CommonRoutines.o
	${FC} ${OPT} -c ${SRCDIR}mpi/BoundaryCommunicator2D_Class.f90 -o $@

# ---------------------------------------------------------------------- #
#                            ~/src/geom/                                 #
# ---------------------------------------------------------------------- #

# Modules 
NodeClass_1D.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o LinkedListClass.o
	${FC} ${OPT} -c ${SRCDIR}geom/NodeClass_1D.f90 -o $@
	
NodeClass_2D.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o  LinkedListClass.o
	${FC} ${OPT} -c ${SRCDIR}geom/NodeClass_2D.f90 -o $@
	
NodeClass_3D.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o LinkedListClass.o
	${FC} ${OPT} -c ${SRCDIR}geom/NodeClass_3D.f90 -o $@

EdgeClass.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o
	${FC} ${OPT} -c ${SRCDIR}geom/EdgeClass.f90 -o $@
	
FaceClass.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o
	${FC} ${OPT} -c ${SRCDIR}geom/FaceClass.f90 -o $@
	
CurveClass_2D.o : ModelPrecision.o ConstantsDictionary.o Lagrange_1D_Class.o
	${FC} ${OPT} -c ${SRCDIR}geom/CurveClass_2D.f90 -o $@	
	
CurveClass_3D.o : ModelPrecision.o ConstantsDictionary.o Lagrange_1D_Class.o
	${FC} ${OPT} -c ${SRCDIR}geom/CurveClass_3D.f90 -o $@	

SurfaceClass_3D.o : ModelPrecision.o ConstantsDictionary.o Lagrange_1D_Class.o Lagrange_2D_Class.o
	${FC} ${OPT} -c ${SRCDIR}geom/SurfaceClass_3D.f90 -o $@	

VectorClass.o : ModelPrecision.o ConstantsDictionary.o
	${FC} ${OPT} -c ${SRCDIR}geom/VectorClass.f90 -o $@

GeometryParamsClass.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o
	${FC} ${OPT} -c ${SRCDIR}geom/GeometryParamsClass.f90 -o $@

HexMeshParamsClass.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o
	${FC} ${OPT} -c ${SRCDIR}geom/Testing/HexMeshParamsClass.f90 -o $@

GeometrySupportRoutines.o : ModelPrecision.o ConstantsDictionary.o Lagrange_1D_Class.o \
                            CurveClass_2D.o CurveClass_3D.o
	${FC} ${OPT} -c ${SRCDIR}geom/GeometrySupportRoutines.f90 -o $@

MappedGeometryClass_1D.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o CommonRoutines.o \
                           Lagrange_1D_Class.o 
	${FC} ${OPT} -c ${SRCDIR}geom/MappedGeometryClass_1D.f90 -o $@

MappedGeometryClass_2D.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o CommonRoutines.o \
                           Lagrange_2D_Class.o CurveClass_2D.o VectorClass.o GeometrySupportRoutines.o
	${FC} ${OPT} -c ${SRCDIR}geom/MappedGeometryClass_2D.f90 -o $@

MappedGeometryClass_3D.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o CommonRoutines.o \
                           Lagrange_3D_Class.o SurfaceClass_3D.o VectorClass.o
	${FC} ${OPT} -c ${SRCDIR}geom/MappedGeometryClass_3D.f90 -o $@

QuadElementClass.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o \
                     Lagrange_2D_Class.o CurveClass_2D.o GeometrySupportRoutines.o MappedGeometryClass_2D.o
	${FC} ${OPT} -c ${SRCDIR}geom/QuadElementClass.f90 -o $@	
	
HexElementClass.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o \
                     Lagrange_3D_Class.o SurfaceClass_3D.o MappedGeometryClass_3D.o
	${FC} ${OPT} -c ${SRCDIR}geom/HexElementClass.f90 -o $@

HexMeshClass.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o LinkedListClass.o KeyRingClass.o \
                 Chebyshev.o Lagrange_3D_Class.o MappedGeometryClass_3D.o HexElementClass.o FaceClass.o \
                 NodeClass_3D.o
	${FC} ${OPT} -c ${SRCDIR}geom/HexMeshClass.f90 -o $@

QuadMeshClass.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o LinkedListClass.o HashTableClass.o \
                  Chebyshev.o Lagrange_2D_Class.o CurveClass_2D.o  MappedGeometryClass_2D.o \
                  QuadElementClass.o EdgeClass.o NodeClass_2D.o
	${FC} ${OPT} -c ${SRCDIR}geom/QuadMeshClass.f90 -o $@	

SegmentMeshClass.o : ModelPrecision.o ConstantsDictionary.o ModelFlags.o \
                     Lagrange_1D_Class.o MappedGeometryClass_1D.o 
	${FC} ${OPT} -c ${SRCDIR}geom/SegmentMeshClass.f90 -o $@


# ---------------------------------------------------------------------- #
#                     ~/src/highend/shallowwater/                        #
# ---------------------------------------------------------------------- #
         
# Modules         
SWParamsClass.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o
	${FC} ${OPT} -c ${SRCDIR}highend/shallowwater/SWParamsClass.f90 -o $@

ShallowWaterClass.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o \
                      Lagrange_2D_Class.o NodalStorage_2D_Class.o DGSEMSolutionStorageClass_2D.o \
                      EdgeClass.o QuadElementClass.o QuadMeshClass.o SWParamsClass.o
	${FC} ${OPT} -c ${SRCDIR}highend/shallowwater/ShallowWaterClass.f90 -o $@


ConservativeShallowWaterClass.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o \
                      Lagrange_2D_Class.o NodalStorage_2D_Class.o DGSEMSolutionStorageClass_2D.o \
                      EdgeClass.o QuadElementClass.o QuadMeshClass.o SWParamsClass.o
	${FC} ${OPT} -c ${SRCDIR}highend/shallowwater/ConservativeShallowWaterClass.f90 -o $@


ConservativeShallowWaterClass_MPI.o : ModelPrecision.o ModelFlags.o ConstantsDictionary.o CommonRoutines.o \
                      Lagrange_2D_Class.o NodalStorage_2D_Class.o DGSEMSolutionStorageClass_2D.o \
                      BoundaryCommunicator2D_Class.o EdgeClass.o QuadElementClass.o QuadMeshClass.o SWParamsClass.o
	${MPIF90} ${OPT} -c ${SRCDIR}highend/shallowwater/ConservativeShallowWaterClass_MPI.f90 ${INC} -o $@


# Test Programs
ShallowWater_InitialConditions.o : ModelPrecision.o QuadMeshClass.o SWParamsClass.o ShallowWaterClass.o
	${FC} ${OPT} -c ${SRCDIR}highend/shallowwater/Testing/ShallowWater_InitialConditions.f90 -o $@

ShallowWater_Driver.o : ModelPrecision.o QuadMeshClass.o SWParamsClass.o ShallowWaterClass.o
	${FC} ${OPT} -c ${SRCDIR}highend/shallowwater/ShallowWater_Driver.f90 -o $@



# ---------------------------------------------------------------------- #
#                          Other directives                              #
# ---------------------------------------------------------------------- #
.PHONY : clean

clean :
	rm *.o *.mod
























