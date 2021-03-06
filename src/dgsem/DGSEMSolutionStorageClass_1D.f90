! DGSEMSolutionStorageClass_1D.f90
! 
! Copyright 2015 Joseph Schoonover <schoonover.numerics@gmail.com>
! 
! DGSEMSolutionStorageClass_1D.f90 is part of the Spectral Element Libraries in Fortran (SELF).
! 
! Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
! and associated documentation files (the "Software"), to deal in the Software without restriction, 
! including without limitation the rights to use, copy, modify, merge, publish, distribute, 
! sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
! furnished to do so, subject to the following conditions: 
! 
! The above copyright notice and this permission notice shall be included in all copies or  
! substantial portions of the Software. 
! 
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
! BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
! NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
! DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
!
! //////////////////////////////////////////////////////////////////////////////////////////////// !
 
 
MODULE DGSEMSolutionStorageClass_1D
! ========================================= Logs ================================================= !
!2016-05-11  Joseph Schoonover  schoonover.numerics@gmail.com 
!
! //////////////////////////////////////////////////////////////////////////////////////////////// ! 
USE ConstantsDictionary
USE ModelPrecision

USE NodalStorage_1D_Class

IMPLICIT NONE


    TYPE DGSEMSolution_1D
      INTEGER                 :: nEq, nS
      REAL(prec), allocatable :: Solution(:,:)
      REAL(prec), allocatable :: tendency(:,:)
      REAL(prec), allocatable :: boundarySolution(:,:)   ! Indexed over the boundaries. 1 is south and proceed counterclockwise
      REAL(prec), allocatable :: boundaryFlux(:,:)  ! Indexed over the boundaries


      CONTAINS

      ! CONSTRUCTORS/DESTRUCTORS
      PROCEDURE :: Build => Build_DGSEMSolution_1D
      PROCEDURE :: Trash => Trash_DGSEMSolution_1D

      ! ACCESSORS
      PROCEDURE :: GetNumberOfEquations => GetNumberOfEquations_DGSEM_1D
      PROCEDURE :: SetNumberOfEquations => SetNumberOfEquations_DGSEM_1D
      
      PROCEDURE :: GetNumberOfNodes => GetNumberOfNodes_DGSEM_1D
      PROCEDURE :: SetNumberOfNodes => SetNumberOfNodes_DGSEM_1D

      PROCEDURE :: GetSolution => GetSolution_DGSEM_1D
      PROCEDURE :: SetSolution => SetSolution_DGSEM_1D
      PROCEDURE :: GetSolutionAtNode => GetSolutionAtNode_DGSEM_1D
      PROCEDURE :: SetSolutionAtNode => SetSolutionAtNode_DGSEM_1D
      PROCEDURE :: GetSolutionWithVarID => GetSolutionWithVarID_DGSEM_1D
      PROCEDURE :: SetSolutionWithVarID => SetSolutionWithVarID_DGSEM_1D
      PROCEDURE :: GetSolutionAtNodeWithVarID => GetSolutionAtNodeWithVarID_DGSEM_1D
      PROCEDURE :: SetSolutionAtNodeWithVarID => SetSolutionAtNodeWithVarID_DGSEM_1D
      
      PROCEDURE :: GetTendency => GetTendency_DGSEM_1D
      PROCEDURE :: SetTendency => SetTendency_DGSEM_1D
      PROCEDURE :: GetTendencyAtNode => GetTendencyAtNode_DGSEM_1D
      PROCEDURE :: SetTendencyAtNode => SetTendencyAtNode_DGSEM_1D
      PROCEDURE :: GetTendencyWithVarID => GetTendencyWithVarID_DGSEM_1D
      PROCEDURE :: SetTendencyWithVarID => SetTendencyWithVarID_DGSEM_1D
      PROCEDURE :: GetTendencyAtNodeWithVarID => GetTendencyAtNodeWithVarID_DGSEM_1D
      PROCEDURE :: SetTendencyAtNodeWithVarID => SetTendencyAtNodeWithVarID_DGSEM_1D
      
      PROCEDURE :: GetBoundarySolution => GetBoundarySolution_DGSEM_1D
      PROCEDURE :: SetBoundarySolution => SetBoundarySolution_DGSEM_1D
      PROCEDURE :: GetBoundarySolutionAtBoundary => GetBoundarySolutionAtBoundary_DGSEM_1D
      PROCEDURE :: SetBoundarySolutionAtBoundary => SetBoundarySolutionAtBoundary_DGSEM_1D
      PROCEDURE :: GetBoundarySolutionWithVarID => GetBoundarySolutionWithVarID_DGSEM_1D
      PROCEDURE :: SetBoundarySolutionWithVarID => SetBoundarySolutionWithVarID_DGSEM_1D
      PROCEDURE :: GetBoundarySolutionAtBoundaryWithVarID => GetBoundarySolutionAtBoundaryWithVarID_DGSEM_1D
      PROCEDURE :: SetBoundarySolutionAtBoundaryWithVarID => SetBoundarySolutionAtBoundaryWithVarID_DGSEM_1D

      PROCEDURE :: GetBoundaryFlux => GetBoundaryFlux_DGSEM_1D
      PROCEDURE :: SetBoundaryFlux => SetBoundaryFlux_DGSEM_1D
      PROCEDURE :: GetBoundaryFluxAtBoundary => GetBoundaryFluxAtBoundary_DGSEM_1D
      PROCEDURE :: SetBoundaryFluxAtBoundary => SetBoundaryFluxAtBoundary_DGSEM_1D
      PROCEDURE :: GetBoundaryFluxWithVarID => GetBoundaryFluxWithVarID_DGSEM_1D
      PROCEDURE :: SetBoundaryFluxWithVarID => SetBoundaryFluxWithVarID_DGSEM_1D
      PROCEDURE :: GetBoundaryFluxAtBoundaryWithVarID => GetBoundaryFluxAtBoundaryWithVarID_DGSEM_1D
      PROCEDURE :: SetBoundaryFluxAtBoundaryWithVarID => SetBoundaryFluxAtBoundaryWithVarID_DGSEM_1D 
      
      PROCEDURE :: CalculateSolutionAtBoundaries => CalculateSolutionAtBoundaries_DGSEMSolution_1D
    END TYPE DGSEMSolution_1D

 
 CONTAINS
!
!
!==================================================================================================!
!------------------------------- Manual Constructors/Destructors ----------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE Build_DGSEMSolution_1D( myDGS, nS, nEq )
 ! S/R Build_DGSEMSolution_1D
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: nS, nEq
   !LOCAL

      
      ALLOCATE( myDGS % solution(0:nS,1:nEq) )
      ALLOCATE( myDGS % tendency(0:nS,1:nEq) )
      ALLOCATE( myDGS % boundarySolution(1:nEq,1:2) ) 
      ALLOCATE( myDGS % boundaryFlux(1:nEq,1:2) ) 

      
      myDGS % solution = ZERO

      myDGS % tendency = ZERO
 
      myDGS % boundarySolution = ZERO

      myDGS % boundaryFlux = ZERO


      CALL myDGS % SetNumberOfEquations( nEq )
      CALL myDGS % SetNumberOfNodes( nS )

 END SUBROUTINE Build_DGSEMSolution_1D
!
!
!
 SUBROUTINE Trash_DGSEMSolution_1D( myDGS )
 ! S/R Trash_DGSEMSolution_1D
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS

      DEALLOCATE( myDGS % Solution )
      DEALLOCATE( myDGS % tendency )
      DEALLOCATE( myDGS % boundarySolution ) 
      DEALLOCATE( myDGS % boundaryFlux ) 

 END SUBROUTINE Trash_DGSEMSolution_1D
!
!
!==================================================================================================!
!--------------------------------------- Accessors ------------------------------------------------!
!==================================================================================================!
!
!
! ------------------------------------ Number of Equations --------------------------------------- !
!
 SUBROUTINE GetNumberOfEquations_DGSEM_1D( myDGS, nEq  )
 ! S/R GetNumberOfEquations_DGSEM_1D
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(out)                :: nEq 

      nEq = myDGS % nEq

 END SUBROUTINE GetNumberOfEquations_DGSEM_1D
!
!
!
 SUBROUTINE SetNumberOfEquations_DGSEM_1D( myDGS, nEq  )
 ! S/R SetNumberOfEquations_DGSEM_1D
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: nEq ! 

      myDGS % nEq = nEq

 END SUBROUTINE SetNumberOfEquations_DGSEM_1D
!
! ------------------------------------- Number of Nodes ------------------------------------------ !
!
 SUBROUTINE GetNumberOfNodes_DGSEM_1D( myDGS, nNodes  )
 ! S/R GetNumberOfNodes
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(out)                :: nNodes 

      nNodes = myDGS % nS

 END SUBROUTINE GetNumberOfNodes_DGSEM_1D
!
!
!
 SUBROUTINE SetNumberOfNodes_DGSEM_1D( myDGS, nNodes  )
 ! S/R SetNumberOfNodes
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: nNodes 

      myDGS % nS = nNodes

 END SUBROUTINE SetNumberOfNodes_DGSEM_1D
!
! ---------------------------------------- Solution ---------------------------------------------- !
!
 SUBROUTINE GetSolution_DGSEM_1D( myDGS, theSolution  )
 ! S/R GetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   REAL(prec), INTENT(out)             :: theSolution(0:myDGS % nS,1:myDGS % nEq)

      theSolution = myDGS % Solution

 END SUBROUTINE GetSolution_DGSEM_1D
!
!
!
 SUBROUTINE SetSolution_DGSEM_1D( myDGS, theSolution  )
 ! S/R SetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   REAL(prec), INTENT(in)                 :: theSolution(0:myDGS % nS,1:myDGS % nEq)
   ! LOCAL

      myDGS % Solution = theSolution

 END SUBROUTINE SetSolution_DGSEM_1D
!
!
!
 SUBROUTINE GetSolutionAtNode_DGSEM_1D( myDGS, iNode, theSolution  )
 ! S/R GetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: iNode 
   REAL(prec), INTENT(out)             :: theSolution(1:myDGS % nEq)

      theSolution = myDGS % Solution(iNode,:)

 END SUBROUTINE GetSolutionAtNode_DGSEM_1D
!
!
!
 SUBROUTINE SetSolutionAtNode_DGSEM_1D( myDGS, iNode, theSolution  )
 ! S/R SetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: iNode 
   REAL(prec), INTENT(in)                 :: theSolution(1:myDGS % nEq)
   ! LOCAL

      myDGS % Solution(iNode,:) = theSolution

 END SUBROUTINE SetSolutionAtNode_DGSEM_1D
!
!
!
SUBROUTINE GetSolutionWithVarID_DGSEM_1D( myDGS, varID, theSolution  )
 ! S/R GetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: varID 
   REAL(prec), INTENT(out)             :: theSolution(0:myDGS % nS)

      theSolution(:) = myDGS % Solution(:,varID)

 END SUBROUTINE GetSolutionWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE SetSolutionWithVarID_DGSEM_1D( myDGS, varID, theSolution  )
 ! S/R SetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: varID 
   REAL(prec), INTENT(in)                 :: theSolution(0:myDGS % nS)

      myDGS % Solution(:,varID) = theSolution

 END SUBROUTINE SetSolutionWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE GetSolutionAtNodeWithVarID_DGSEM_1D( myDGS, iNode, varID, theSolution  )
 ! S/R GetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: iNode, varID 
   REAL(prec), INTENT(out)             :: theSolution

      theSolution = myDGS % Solution(iNode,varID)

 END SUBROUTINE GetSolutionAtNodeWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE SetSolutionAtNodeWithVarID_DGSEM_1D( myDGS, iNode, varID, theSolution  )
 ! S/R SetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: iNode, varID 
   REAL(prec), INTENT(in)                 :: theSolution
   ! LOCAL

      myDGS % Solution(iNode,varID) = theSolution

 END SUBROUTINE SetSolutionAtNodeWithVarID_DGSEM_1D
!
! ----------------------------------------- Tendency --------------------------------------------- !
!
 SUBROUTINE GetTendency_DGSEM_1D( myDGS, theTend  )
 ! S/R GetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   REAL(prec), INTENT(out)             :: theTend(0:myDGS % nS,1:myDGS % nEq)

      theTend = myDGS % tendency

 END SUBROUTINE GetTendency_DGSEM_1D
!
!
!
 SUBROUTINE SetTendency_DGSEM_1D( myDGS, theTend  )
 ! S/R SetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   REAL(prec), INTENT(in)                 :: theTend(0:myDGS % nS,1:myDGS % nEq)
   ! LOCAL

      myDGS % tendency = theTend

 END SUBROUTINE SetTendency_DGSEM_1D
!
!
!
 SUBROUTINE GetTendencyAtNode_DGSEM_1D( myDGS, iNode, theTend  )
 ! S/R GetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: iNode 
   REAL(prec), INTENT(out)             :: theTend(1:myDGS % nEq)

      theTend = myDGS % tendency(iNode,:)

 END SUBROUTINE GetTendencyAtNode_DGSEM_1D
!
!
!
 SUBROUTINE SetTendencyAtNode_DGSEM_1D( myDGS, iNode, theTend  )
 ! S/R SetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: iNode 
   REAL(prec), INTENT(in)                 :: theTend(1:myDGS % nEq)
   ! LOCAL

      myDGS % tendency(iNode,:) = theTend

 END SUBROUTINE SetTendencyAtNode_DGSEM_1D
!
!
!
SUBROUTINE GetTendencyWithVarID_DGSEM_1D( myDGS, varID, theTend  )
 ! S/R GetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: varID 
   REAL(prec), INTENT(out)             :: theTend(0:myDGS % nS)

      theTend(:) = myDGS % tendency(:,varID)

 END SUBROUTINE GetTendencyWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE SetTendencyWithVarID_DGSEM_1D( myDGS, varID, theTend  )
 ! S/R SetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: varID 
   REAL(prec), INTENT(in)                 :: theTend(0:myDGS % nS)

      myDGS % tendency(:,varID) = theTend

 END SUBROUTINE SetTendencyWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE GetTendencyAtNodeWithVarID_DGSEM_1D( myDGS, iNode, varID, theTend  )
 ! S/R GetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: iNode, varID 
   REAL(prec), INTENT(out)             :: theTend

      theTend = myDGS % tendency(iNode,varID)

 END SUBROUTINE GetTendencyAtNodeWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE SetTendencyAtNodeWithVarID_DGSEM_1D( myDGS, iNode, varID, theTend  )
 ! S/R SetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: iNode, varID 
   REAL(prec), INTENT(in)                 :: theTend
   ! LOCAL

      myDGS % tendency(iNode,varID) = theTend

 END SUBROUTINE SetTendencyAtNodeWithVarID_DGSEM_1D
!
! ------------------------------- Boundary Solution ---------------------------------------------- !
!
 SUBROUTINE GetBoundarySolution_DGSEM_1D( myDGS, theSolution  )
 ! S/R GetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   REAL(prec), INTENT(out)             :: theSolution(1:myDGS % nEq,1:2)

      theSolution = myDGS % boundarySolution

 END SUBROUTINE GetBoundarySolution_DGSEM_1D
!
!
!
 SUBROUTINE SetBoundarySolution_DGSEM_1D( myDGS, theSolution  )
 ! S/R SetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   REAL(prec), INTENT(in)                 :: theSolution(1:myDGS % nEq,1:2)
   ! LOCAL

      myDGS % boundarySolution = theSolution

 END SUBROUTINE SetBoundarySolution_DGSEM_1D
!
!
!
 SUBROUTINE GetBoundarySolutionAtBoundary_DGSEM_1D( myDGS, boundary, theSolution  )
 ! S/R GetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: boundary
   REAL(prec), INTENT(out)             :: theSolution(1:myDGS % nEq)

      theSolution = myDGS % boundarySolution(1:myDGS % nEq,boundary)

 END SUBROUTINE GetBoundarySolutionAtBoundary_DGSEM_1D
!
!
!
 SUBROUTINE SetBoundarySolutionAtBoundary_DGSEM_1D( myDGS, boundary, theSolution  )
 ! S/R SetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: boundary
   REAL(prec), INTENT(in)                 :: theSolution(1:myDGS % nEq)
   ! LOCAL

      myDGS % boundarySolution(1:myDGS % nEq,boundary) = theSolution

 END SUBROUTINE SetBoundarySolutionAtBoundary_DGSEM_1D
!
!
!
SUBROUTINE GetBoundarySolutionWithVarID_DGSEM_1D( myDGS, varID, theSolution  )
 ! S/R GetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: varID 
   REAL(prec), INTENT(out)             :: theSolution(1:2)

      theSolution = myDGS % boundarySolution(varID,1:2)

 END SUBROUTINE GetBoundarySolutionWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE SetBoundarySolutionWithVarID_DGSEM_1D( myDGS, varID, theSolution  )
 ! S/R SetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: varID 
   REAL(prec), INTENT(in)                 :: theSolution(1:2)

      myDGS % boundarySolution(varID,1:2) = theSolution

 END SUBROUTINE SetBoundarySolutionWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE GetBoundarySolutionAtBoundaryWithVarID_DGSEM_1D( myDGS, boundary, varID, theSolution  )
 ! S/R GetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: boundary, varID 
   REAL(prec), INTENT(out)             :: theSolution

      theSolution = myDGS % boundarySolution(varID,boundary)

 END SUBROUTINE GetBoundarySolutionAtBoundaryWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE SetBoundarySolutionAtBoundaryWithVarID_DGSEM_1D( myDGS, boundary, varID, theSolution  )
 ! S/R SetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: boundary, varID 
   REAL(prec), INTENT(in)                 :: theSolution
   ! LOCAL

      myDGS % boundarySolution(varID, boundary) = theSolution

 END SUBROUTINE SetBoundarySolutionAtBoundaryWithVarID_DGSEM_1D
!
! --------------------------------- Boundary Flux ------------------------------------------------ !
!
 SUBROUTINE GetBoundaryFlux_DGSEM_1D( myDGS, theFlux  )
 ! S/R GetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   REAL(prec), INTENT(out)             :: theFlux(1:myDGS % nEq,1:2)

      theFlux = myDGS % boundaryFlux

 END SUBROUTINE GetBoundaryFlux_DGSEM_1D
!
!
!
 SUBROUTINE SetBoundaryFlux_DGSEM_1D( myDGS, theFlux  )
 ! S/R SetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   REAL(prec), INTENT(in)                 :: theFlux(1:myDGS % nEq,1:2)
   ! LOCAL

      myDGS % boundaryFlux = theFlux

 END SUBROUTINE SetBoundaryFlux_DGSEM_1D
!
!
!
 SUBROUTINE GetBoundaryFluxAtBoundary_DGSEM_1D( myDGS, boundary, theFlux  )
 ! S/R GetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: boundary
   REAL(prec), INTENT(out)             :: theFlux(1:myDGS % nEq)

      theFlux = myDGS % boundaryFlux(1:myDGS % nEq,boundary)

 END SUBROUTINE GetBoundaryFluxAtBoundary_DGSEM_1D
!
!
!
 SUBROUTINE SetBoundaryFluxAtBoundary_DGSEM_1D( myDGS, boundary, theFlux  )
 ! S/R SetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: boundary
   REAL(prec), INTENT(in)                 :: theFlux(1:myDGS % nEq)
   ! LOCAL

      myDGS % boundaryFlux(1:myDGS % nEq,boundary) = theFlux

 END SUBROUTINE SetBoundaryFluxAtBoundary_DGSEM_1D
!
!
!
SUBROUTINE GetBoundaryFluxWithVarID_DGSEM_1D( myDGS, varID, theFlux  )
 ! S/R GetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: varID 
   REAL(prec), INTENT(out)             :: theFlux(1:2)

      theFlux = myDGS % boundaryFlux(varID,1:2)

 END SUBROUTINE GetBoundaryFluxWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE SetBoundaryFluxWithVarID_DGSEM_1D( myDGS, varID, theFlux  )
 ! S/R SetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: varID 
   REAL(prec), INTENT(in)                 :: theFlux(1:2)

      myDGS % boundaryFlux(varID,1:2) = theFlux

 END SUBROUTINE SetBoundaryFluxWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE GetBoundaryFluxAtBoundaryWithVarID_DGSEM_1D( myDGS, boundary, varID, theFlux  )
 ! S/R GetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(in) :: myDGS
   INTEGER, INTENT(in)                 :: boundary, varID 
   REAL(prec), INTENT(out)             :: theFlux

      theFlux = myDGS % boundaryFlux(varID,boundary)

 END SUBROUTINE GetBoundaryFluxAtBoundaryWithVarID_DGSEM_1D
!
!
!
 SUBROUTINE SetBoundaryFluxAtBoundaryWithVarID_DGSEM_1D( myDGS, boundary, varID, theFlux  )
 ! S/R SetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   INTEGER, INTENT(in)                    :: boundary, varID 
   REAL(prec), INTENT(in)                 :: theFlux
   ! LOCAL

      myDGS % boundaryFlux(varID, boundary) = theFlux

 END SUBROUTINE SetBoundaryFluxAtBoundaryWithVarID_DGSEM_1D
!
!
!==================================================================================================!
!--------------------------------- Type Specific Routines -----------------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE CalculateSolutionAtBoundaries_DGSEMSolution_1D( myDGS, dgStorage )
 ! S/R CalculateSolutionAtBoundaries
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(DGSEMSolution_1D), INTENT(inout) :: myDGS
   TYPE(NodalStorage_1D), INTENT(in)      :: dgStorage
   ! LOCAL
   INTEGER :: iS, iEq, nS,  nEq
   REAL(prec) :: lagWest(0:myDGS % nS)
   REAL(prec) :: lagEast(0:myDGS % nS)
   
      CALL myDGS % GetNumberOfEquations( nEq )
      CALL myDGS % GetNumberOfNodes( nS )
      
      CALL dgStorage % GetEasternInterpolants( lagEast )
      CALL dgStorage % GetWesternInterpolants( lagWest )
       
      DO iEq = 1, nEq ! Loop over the number of equations
          
         ! Setting the "west boundary"
         myDGS % boundarySolution(iEq,1) = DOT_PRODUCT( lagWest, myDGS % solution(:,iEq) )

         ! Setting the "east boundary"
         myDGS % boundarySolution(iEq,2) = DOT_PRODUCT( lagEast, myDGS % solution(:,iEq) )

       ENDDO 
         
   
 END SUBROUTINE CalculateSolutionAtBoundaries_DGSEMSolution_1D
!
!
!
END MODULE DGSEMSolutionStorageClass_1D
