! HydrostaticPrimitivesClass.f90
! 
! Copyright 2015 Joseph Schoonover <schoonover.numerics@gmail.com>
! 
! HydrostaticPrimitivesClass.f90 is part of the Spectral Element Libraries in Fortran (SELF).
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
 
 
MODULE HydrostaticPrimitivesClass
! ========================================= Logs ================================================= !
!2016-05-11  Joseph Schoonover  schoonover.numerics@gmail.com 
!
! //////////////////////////////////////////////////////////////////////////////////////////////// ! 

! src/common/
USE ModelPrecision
USE ConstantsDictionary
USE ModelFlags
USE CommonRoutines
USE Timing
! src/interp/
USE Lagrange_1D_Class
USE Lagrange_2D_Class
USE Lagrange_3D_Class
! src/nodal/
USE NodalStorage_1D_Class
USE NodalStorage_2D_Class
USE NodalStorage_3D_Class
! src/dgsem/
USE DGSEMSolutionStorageClass_3D
! src/cgsem/
!USE Elliptic2d_Class
! src/filters/
!USE RollOffFilter3D_Class
! src/geometry/
USE QuadMeshClass
USE FaceClass
USE HexElementClass  
USE HexMeshClass   
USE StackedHexMeshClass 
! src/highend/hydrostaticprimitives/
USE HydrostaticParams_Class
USE ConservativeShallowWaterClass
!


! Parallel Libraries
USE OMP_LIB


IMPLICIT NONE
!
! Some parameters that are specific to this module
     

! ================================================================================================ !
!     The HydrostaticPrimitive is based on the DGSEM_3D framework. An Adaptive Roll-off Filter (ARF) is applied
!     to prevent the buildup of aliasing errors that can lead to spurious numerical oscillations 
!     and possibly instability. The adaptive algorithm is similar to [ Flad, Beck, and Munz (2016) ] 
!     but has been modified to use a roll-off filter and is applied to a passive tracer.
! ================================================================================================ !  


    TYPE HydrostaticPrimitive
      INTEGER                               :: nEq, nPlot, nS, nP, nQ
      TYPE( StackedHexMesh )                :: mesh
      TYPE( NodalStorage_1D )               :: intStorage
      TYPE( NodalStorage_3D )               :: dGStorage
      TYPE( ShallowWater )                  :: barotropic
      TYPE( DGSEMSolution_3D ), ALLOCATABLE :: prevSol(:)
      TYPE( DGSEMSolution_3D ), ALLOCATABLE :: sol(:)
      TYPE( DGSEMSolution_3D ), ALLOCATABLE :: baroclinic(:)
      TYPE( DGSEMSolution_3D ), ALLOCATABLE :: background(:)
      REAL(prec), ALLOCATABLE               :: planetaryVorticity(:,:,:,:)
      REAL(prec), ALLOCATABLE               :: bottomW(:,:,:)
      REAL(prec), ALLOCATABLE               :: U(:,:,:), V(:,:,:) ! Transport


      TYPE( HydrostaticParams )             :: params
      TYPE( MultiTimers )                   :: clocks
      REAL(prec), ALLOCATABLE               :: plMatS(:,:), plMatP(:,:), plMatQ(:,:)


      CONTAINS

      PROCEDURE :: Build => Build_HydrostaticPrimitive
      PROCEDURE :: Trash => Trash_HydrostaticPrimitive
      PROCEDURE :: BuildHexMesh => BuildHexMesh_HydrostaticPrimitive
      
      ! DGSEMSolution_3DStorage_Class Wrapper Routines
      PROCEDURE :: GetSolution => GetSolution_HydrostaticPrimitive
      PROCEDURE :: SetSolution => SetSolution_HydrostaticPrimitive
      PROCEDURE :: GetSolutionWithVarID => GetSolutionWithVarID_HydrostaticPrimitive
      PROCEDURE :: SetSolutionWithVarID => SetSolutionWithVarID_HydrostaticPrimitive
      PROCEDURE :: GetSolutionAtNode => GetSolutionAtNode_HydrostaticPrimitive
      PROCEDURE :: SetSolutionAtNode => SetSolutionAtNode_HydrostaticPrimitive
      PROCEDURE :: GetSolutionAtNodeWithVarID => GetSolutionAtNodeWithVarID_HydrostaticPrimitive
      PROCEDURE :: SetSolutionAtNodeWithVarID => SetSolutionAtNodeWithVarID_HydrostaticPrimitive
      PROCEDURE :: GetSolutionAtBoundary => GetSolutionAtBoundary_HydrostaticPrimitive
      PROCEDURE :: SetSolutionAtBoundary => SetSolutionAtBoundary_HydrostaticPrimitive

      PROCEDURE :: GetBackgroundState => GetBackgroundState_HydrostaticPrimitive
      PROCEDURE :: SetBackgroundState => SetBackgroundState_HydrostaticPrimitive
      PROCEDURE :: GetBackgroundStateWithVarID => GetBackgroundStateWithVarID_HydrostaticPrimitive
      PROCEDURE :: SetBackgroundStateWithVarID => SetBackgroundStateWithVarID_HydrostaticPrimitive
      PROCEDURE :: GetBackgroundStateAtNode => GetBackgroundStateAtNode_HydrostaticPrimitive
      PROCEDURE :: SetBackgroundStateAtNode => SetBackgroundStateAtNode_HydrostaticPrimitive
      PROCEDURE :: GetBackgroundStateAtNodeWithVarID => GetBackgroundStateAtNodeWithVarID_HydrostaticPrimitive
      PROCEDURE :: SetBackgroundStateAtNodeWithVarID => SetBackgroundStateAtNodeWithVarID_HydrostaticPrimitive
      PROCEDURE :: GetBackgroundStateAtBoundary => GetBackgroundStateAtBoundary_HydrostaticPrimitive
      PROCEDURE :: SetBackgroundStateAtBoundary => SetBackgroundStateAtBoundary_HydrostaticPrimitive

      PROCEDURE :: GetPlanetaryVorticity => GetPlanetaryVorticity_HydrostaticPrimitive
      PROCEDURE :: SetPlanetaryVorticity => SetPlanetaryVorticity_HydrostaticPrimitive
      PROCEDURE :: GetPlanetaryVorticityAtNode => GetPlanetaryVorticityAtNode_HydrostaticPrimitive
      PROCEDURE :: SetPlanetaryVorticityAtNode => SetPlanetaryVorticityAtNode_HydrostaticPrimitive

      PROCEDURE :: GetPreviousTendency => GetPreviousTendency_HydrostaticPrimitive
      PROCEDURE :: SetPreviousTendency => SetPreviousTendency_HydrostaticPrimitive
      PROCEDURE :: GetTendency => GetTendency_HydrostaticPrimitive
      PROCEDURE :: SetTendency => SetTendency_HydrostaticPrimitive
      PROCEDURE :: GetTendencyAtNode => GetTendencyAtNode_HydrostaticPrimitive
      PROCEDURE :: SetTendencyAtNode => SetTendencyAtNode_HydrostaticPrimitive
      PROCEDURE :: GetTendencyWithVarID => GetTendencyWithVarID_HydrostaticPrimitive
      PROCEDURE :: SetTendencyWithVarID => SetTendencyWithVarID_HydrostaticPrimitive
      PROCEDURE :: GetTendencyAtNodeWithVarID => GetTendencyAtNodeWithVarID_HydrostaticPrimitive
      PROCEDURE :: SetTendencyAtNodeWithVarID => SetTendencyAtNodeWithVarID_HydrostaticPrimitive

      PROCEDURE :: GetFluxAtBoundary => GetFluxAtBoundary_HydrostaticPrimitive
      PROCEDURE :: SetFluxAtBoundary => SetFluxAtBoundary_HydrostaticPrimitive
      PROCEDURE :: GetFluxAtBoundaryNode => GetFluxAtBoundaryNode_HydrostaticPrimitive
      PROCEDURE :: SetFluxAtBoundaryNode => SetFluxAtBoundaryNode_HydrostaticPrimitive

      ! Extensions of the DGSEMSolutionStorage_Class Wrapper Routines
      PROCEDURE :: GetVelocity => GetVelocity_HydrostaticPrimitive
      PROCEDURE :: SetVelocity => SetVelocity_HydrostaticPrimitive
      PROCEDURE :: GetVelocityAtBoundary => GetVelocityAtBoundary_HydrostaticPrimitive
      PROCEDURE :: SetVelocityAtBoundary => SetVelocityAtBoundary_HydrostaticPrimitive
      PROCEDURE :: GetVelocityAtBoundaryNode => GetVelocityAtBoundaryNode_HydrostaticPrimitive
      PROCEDURE :: SetVelocityAtBoundaryNode => SetVelocityAtBoundaryNode_HydrostaticPrimitive
      PROCEDURE :: GetBuoyancy => GetBuoyancy_HydrostaticPrimitive
      PROCEDURE :: SetBuoyancy => SetBuoyancy_HydrostaticPrimitive
      PROCEDURE :: GetBuoyancyAtBoundary => GetBuoyancyAtBoundary_HydrostaticPrimitive
      PROCEDURE :: SetBuoyancyAtBoundary => SetBuoyancyAtBoundary_HydrostaticPrimitive
      PROCEDURE :: GetBuoyancyAtBoundaryNode => GetBuoyancyAtBoundaryNode_HydrostaticPrimitive
      PROCEDURE :: SetBuoyancyAtBoundaryNode => SetBuoyancyAtBoundaryNode_HydrostaticPrimitive
     
      
       ! Type Specific Routines 
      PROCEDURE :: GlobalTimeDerivative            => GlobalTimeDerivative_HydrostaticPrimitive
      PROCEDURE :: ForwardStepAB2                  => ForwardStepAB2_HydrostaticPrimitive
      PROCEDURE :: EdgeFlux                        => EdgeFlux_HydrostaticPrimitive
      PROCEDURE :: MappedTimeDerivative            => MappedTimeDerivative_HydrostaticPrimitive 
      PROCEDURE :: CalculateSolutionAtBoundaries   => CalculateSolutionAtBoundaries_HydrostaticPrimitive

      PROCEDURE :: CalculateBaroclinicFields       => CalculateBaroclinicFields_HydrostaticPrimitive
      PROCEDURE :: CalculateBaroclinicVelocity     => CalculateBaroclinicVelocity_HydrostaticPrimitive
      PROCEDURE :: BaroclinicEdgeFlux              => BaroclinicEdgeFlux_HydrostaticPrimitive
      PROCEDURE :: BaroclinicTendency              => BaroclinicTendency_HydrostaticPrimitive
      PROCEDURE :: CalculateSourceForBarotropic    => CalculateSourceForBarotropic_HydrostaticPrimitive

      PROCEDURE :: AdjustVelocity                  => AdjustVelocity_HydrostaticPrimitive
      PROCEDURE :: CalculateBottomVerticalVelocity => CalculateBottomVerticalVelocity_HydrostaticPrimitive
      PROCEDURE :: DiagnoseW                       => DiagnoseW_HydrostaticPrimitive
      PROCEDURE :: DiagnoseP                       => DiagnoseP_HydrostaticPrimitive

      
      PROCEDURE :: CoarseToFine => CoarseToFine_HydrostaticPrimitive
      PROCEDURE :: WriteTecplot => WriteTecplot_HydrostaticPrimitive
      PROCEDURE :: WritePickup => WritePickup_HydrostaticPrimitive
      PROCEDURE :: ReadPickup => ReadPickup_HydrostaticPrimitive

    END TYPE HydrostaticPrimitive


 INTEGER, PARAMETER, PRIVATE :: nDim = 3
 INTEGER, PARAMETER, PRIVATE :: nPrognostic = 3
 INTEGER, PARAMETER, PRIVATE :: nHPEq = 5
 INTEGER, PARAMETER, PRIVATE :: bEq = 3 ! equation id for the buoyancy
 INTEGER, PARAMETER, PRIVATE :: wEq = 4 ! equation id for vertical velocity
 INTEGER, PARAMETER, PRIVATE :: pEq = 5 ! equation id for the hydrostatic pressure


 INTEGER, PARAMETER :: csabTimer  = 1
 INTEGER, PARAMETER :: cdivuTimer = 2
 INTEGER, PARAMETER :: diagpTimer = 3
 INTEGER, PARAMETER :: diagwTimer = 4
 INTEGER, PARAMETER :: efluxTimer = 5
 INTEGER, PARAMETER :: mtdTimer   = 6
 INTEGER, PARAMETER :: ffsTimer   = 7
 INTEGER, PARAMETER :: fssTimer   = 8
 INTEGER, PARAMETER :: vadjTimer  = 9
 INTEGER, PARAMETER :: fIOTimer   = 10

 CONTAINS
!
!
!==================================================================================================!
!------------------------------- Manual Constructors/Destructors ----------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE Build_HydrostaticPrimitive( myDGSEM, initializeOnly )
 ! S/R Build
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   LOGICAL, INTENT(in)                        :: initializeOnly
   !LOCAL
   INTEGER :: iEl, iS, iP, nS, nP, nQ, nPlot, tID, M
   REAL(prec), ALLOCATABLE ::sNew(:)

      CALL myDGSEM % params % Build( )

      !  /////// Clock setup //////// !
      CALL myDGSEM % clocks % Build( )


      CALL myDGSEM % clocks % AddTimer( 'CalculateSolutionAtBoundaries', csabTimer )
      CALL myDGSEM % clocks % AddTimer( 'CalculateDivU', cdivuTimer )
      CALL myDGSEM % clocks % AddTimer( 'DiagnoseP', diagpTimer )
      CALL myDGSEM % clocks % AddTimer( 'DiagnoseW', diagwTimer )
      CALL myDGSEM % clocks % AddTimer( 'EdgeFlux', efluxTimer )
      CALL myDGSEM % clocks % AddTimer( 'MappedTimeDerivative', mtdTimer )
      CALL myDGSEM % clocks % AddTimer( 'FillFreeSurfRHS', ffsTimer )
      CALL myDGSEM % clocks % AddTimer( 'FreeSurfaceSolve', fssTimer )
      CALL myDGSEM % clocks % AddTimer( 'AdjustVelocity', vadjTimer )
      CALL myDGSEM % clocks % AddTimer( 'File-I/O', fIOTimer )
      ! ///////////////////////////// !

      nS = myDGSEM % params % polyDeg
      nP = nS
      nQ = nS
      myDGSEM % nS      = nS
      myDGSEM % nP      = nP
      myDGSEM % nQ      = nQ
      myDGSEM % nEq     = nHPEq
      myDGSEM % nPlot   = myDGSEM % params % nPlot
      
      nPlot = myDGSEM % params % nPlot

      ALLOCATE( sNew(0:nPlot) )

      CALL myDGSEM % dGStorage % Build( nS, nP, nQ, GAUSS, DG )
      M = (nQ+1)/2 + 1
      CALL myDGSEM % intStorage % Build( M, GAUSS_LOBATTO, CG )

      CALL myDGSEM % barotropic % Build( myDGSEM % params )
      CALL myDGSEM % BuildHexMesh( )

      ! Set up the solution
      ALLOCATE( myDGSEM % sol(1:myDGSEM % mesh % nElems) )
      ALLOCATE( myDGSEM % prevsol(1:myDGSEM % mesh % nElems) )
      ALLOCATE( myDGSEM % baroclinic(1:myDGSEM % mesh % nElems) )
      ALLOCATE( myDGSEM % background(1:myDGSEM % mesh % nElems) )

      DO iEl = 1, myDGSEM % mesh % nElems
         CALL myDGSEM % prevSol(iEl) % Build( nS, nP, nQ )
         CALL myDGSEM % sol(iEl) % Build( nS, nP, nQ, nHPEq )
         CALL myDGSEM % baroclinic(iEl) % Build( nS, nP, nQ, nHPEq )
         CALL myDGSEM % background(iEl) % Build( nS, nP, nQ, nHPEq )
      ENDDO

      ALLOCATE( myDGSEM % bottomW(0:nS,0:nS,1:myDGSEM % mesh % nHElems) )
      ALLOCATE( myDGSEM % U(0:nS,0:nS,1:myDGSEM % mesh % nHElems) )
      ALLOCATE( myDGSEM % V(0:nS,0:nS,1:myDGSEM % mesh % nHElems) )
      ALLOCATE( myDGSEM % planetaryVorticity(0:nS,0:nP,0:nQ,1:myDGSEM % mesh % nElems) )
   
      myDGSEM % bottomW            = ZERO
      myDGSEM % U                  = ZERO
      myDGSEM % V                  = ZERO
      myDGSEM % planetaryVorticity = ZERO

      ! In the event that this is a pickup run, we'll READ the pickup file here for the solution 
      ! and the relaxation fields. A negative initial iterate can be used to specify to start 
      ! from zeros.
      
      IF( InitializeOnly .EQV. .FALSE. )then
         
         ! This call reads the solution, the addons and the relaxation-parameter
         CALL myDGSEM % ReadPickup( myDGSEM % params % iterInit )

      ENDIF
      
      nPlot = myDGSEM % params % nPlot
      myDGSEM % nPlot = nPlot
      
      sNew = UniformPoints( -ONE, ONE, nPlot )
      ALLOCATE( myDGSEM % plMatS(0:nPlot,0:nS), myDGSEM % plMatP(0:nPlot,0:nP), myDGSEM % plMatQ(0:nPlot,0:nQ) )
      ! Build the plotting matrix
      CALL myDGSEM % dgStorage % interp % CalculateInterpolationMatrix( nPlot, nPlot, nPlot, &
                                                                        sNew, sNew, sNew, &
                                                                        myDGSEM % plMatS, &
                                                                        myDGSEM % plMatP, &
                                                                        myDGSEM % plMatQ )
      DEALLOCATE( sNew )

 END SUBROUTINE Build_HydrostaticPrimitive
!
!
!
 SUBROUTINE Trash_HydrostaticPrimitive( myDGSEM )
 ! S/R Trash
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   ! LOCAL
   INTEGER :: iEl

     CALL myDGSEM % clocks % Write_MultiTimers( )

     DO iEl = 1, myDGSEM % mesh % nElems
        CALL myDGSEM % prevSol(iEl) % Trash( )
        CALL myDGSEM % sol(iEl) % Trash( )
        CALL myDGSEM % background(iEl) % Trash( )
     ENDDO
    
     CALL myDGSEM % dGStorage % Trash( )
     CALL myDGSEM % intStorage % Trash( )
     
     CALL myDGSEM % mesh % Trash( )
     
     CALL myDGSEM % clocks % Trash( )
     CALL myDGSEM % barotropic % Trash( )
 
      DEALLOCATE( myDGSEM % sol ) 
      DEALLOCATE( myDGSEM % background )
      DEALLOCATE( myDGSEM % bottomW ) 
      DEALLOCATE( myDGSEM % U, myDGSEM % V )
      DEALLOCATE( myDGSEM % planetaryVorticity )
      DEALLOCATE( myDGSEM % plMatS, myDGSEM % plMatP, myDGSEM % plMatQ ) 

 END SUBROUTINE Trash_HydrostaticPrimitive
!
!
!
 SUBROUTINE BuildHexMesh_HydrostaticPrimitive( myDGSEM )
 ! S/R BuildHexMesh
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   ! LOCAL
   REAL(prec), ALLOCATABLE :: h(:,:,:), locH(:,:,:)
   INTEGER                 :: nS, nHElems, iEl

      nS = myDGSEM % params % polyDeg
   
      PRINT*,'Module HydrostaticPrimitiveClass.f90 : S/R BuildHexMesh :'

      nHElems = myDGSEM % barotropic % mesh % nElems

      ALLOCATE( h(0:nS,0:nS,1:nHElems), locH(0:nS,0:nS,1:3) )
      DO iEl = 1, nHElems
         CALL myDGSEM % barotropic % GetBathymetry( iEl, locH )
         h(:,:,iEl) = locH(:,:,1)
      ENDDO
     
      CALL myDGSEM % mesh % TerrainFollowingMesh( myDGSEM % dgStorage % interp, &
                                                  myDGSEM % barotropic % mesh, &
                                                  myDGSEM % barotropic % dgStorage % interp, &
                                                  myDGSEM % params % nZElem, h )

      DEALLOCATE( h, locH )
      

 END SUBROUTINE BuildHexMesh_HydrostaticPrimitive
!
!
!==================================================================================================!
!--------------------------------------- Accessors ------------------------------------------------!
!==================================================================================================!
!
!
!
!--------------------------------------------------------------------------------------------------!
!                                          Solution                                                !
!--------------------------------------------------------------------------------------------------!
!
 SUBROUTINE GetSolution_HydrostaticPrimitive( myDGSEM, iEl, theSolution  )
 ! S/R GetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   REAL(prec), INTENT(out)                 :: theSolution(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ,  1:myDGSEM % nEq)

      CALL myDGSEM % sol(iEl) % GetSolution( theSolution )

 END SUBROUTINE GetSolution_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetSolution_HydrostaticPrimitive( myDGSEM, iEl, theSolution  )
 ! S/R SetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   REAL(prec), INTENT(in)                     :: theSolution(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ,  1:myDGSEM % nEq)

      CALL myDGSEM % sol(iEl) % SetSolution( theSolution )

 END SUBROUTINE SetSolution_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetSolutionWithVarID_HydrostaticPrimitive( myDGSEM, iEl, varID, theSolution  )
 ! S/R GetSolutionWithVarID
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl, varID
   REAL(prec), INTENT(out)                 :: theSolution(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)

      CALL myDGSEM % sol(iEl) % GetSolutionWithVarID( varID, theSolution )

 END SUBROUTINE GetSolutionWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetSolutionWithVarID_HydrostaticPrimitive( myDGSEM, iEl, varID, theSolution  )
 ! S/R SetSolutionWithVarID
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl, varID
   REAL(prec), INTENT(in)                     :: theSolution(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)

      CALL myDGSEM % sol(iEl) % SetSolutionWithVarID( varID, theSolution )

 END SUBROUTINE SetSolutionWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetSolutionAtNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, theSolution  )
 ! S/R GetSolutionAtNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   INTEGER, INTENT(in)                     :: i, j, k
   REAL(prec), INTENT(out)                 :: theSolution(1:myDGSEM % nEq)

      CALL myDGSEM % sol(iEl) % GetSolutionAtNode( i, j, k, theSolution )

 END SUBROUTINE GetSolutionAtNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetSolutionAtNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, theSolution  )
 ! S/R SetSolutionAtNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   INTEGER, INTENT(in)                        :: i, j, k
   REAL(prec), INTENT(in)                     :: theSolution(1:myDGSEM % nEq)

      CALL myDGSEM % sol(iEl) % SetSolutionAtNode( i, j, k, theSolution )

 END SUBROUTINE SetSolutionAtNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetSolutionAtNodeWithVarID_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, varID, theSolution  )
 ! S/R GetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   INTEGER, INTENT(in)          :: i, j, k, varID 
   REAL(prec), INTENT(out)      :: theSolution

      CALL myDGSEM % sol(iEl) % GetSolutionAtNodeWithVarID( i, j, k, varID, theSolution )

 END SUBROUTINE GetSolutionAtNodeWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetSolutionAtNodeWithVarID_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, varID, theSolution  )
 ! S/R SetSolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   INTEGER, INTENT(in)             :: i, j, k, varID 
   REAL(prec), INTENT(in)          :: theSolution

      CALL myDGSEM % sol(iEl) % SetSolutionAtNodeWithVarID( i, j, k, varID, theSolution )

 END SUBROUTINE SetSolutionAtNodeWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetSolutionAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, theSolution  )
 ! S/R GetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   INTEGER, INTENT(in)          :: boundary
   REAL(prec), INTENT(out)      :: theSolution(0:myDGSEM % nS, 0:myDGSEM % nP, 1:myDGSEM % nEq)

      CALL myDGSEM % sol(iEl) % GetBoundarySolutionAtBoundary( boundary, theSolution )

 END SUBROUTINE GetSolutionAtBoundary_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetSolutionAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, theSolution  )
 ! S/R SetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   INTEGER, INTENT(in)             :: boundary
   REAL(prec), INTENT(in)          :: theSolution(0:myDGSEM % nS, 0:myDGSEM % nP, 1:myDGSEM % nEq)

      CALL myDGSEM % sol(iEl) % SetBoundarySolutionAtBoundary( boundary, theSolution )

 END SUBROUTINE SetSolutionAtBoundary_HydrostaticPrimitive
!
!--------------------------------------------------------------------------------------------------!
!                                       BackgroundState                                            !
!--------------------------------------------------------------------------------------------------!
!
 SUBROUTINE GetBackgroundState_HydrostaticPrimitive( myDGSEM, iEl, theBackgroundState  )
 ! S/R GetBackgroundState
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   REAL(prec), INTENT(out)                 :: theBackgroundState(0:myDGSEM % nS, &
                                                                 0:myDGSEM % nP, &
                                                                 0:myDGSEM % nQ, &
                                                                 1:myDGSEM % nEq)

      CALL myDGSEM % background(iEl) % GetSolution( theBackgroundState )

 END SUBROUTINE GetBackgroundState_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetBackgroundState_HydrostaticPrimitive( myDGSEM, iEl, theBackgroundState  )
 ! S/R SetBackgroundState
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   REAL(prec), INTENT(in)                     :: theBackgroundState(0:myDGSEM % nS, &
                                                                    0:myDGSEM % nP, &
                                                                    0:myDGSEM % nQ, &
                                                                    1:myDGSEM % nEq)

      CALL myDGSEM % background(iEl) % SetSolution( theBackgroundState )

 END SUBROUTINE SetBackgroundState_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetBackgroundStateWithVarID_HydrostaticPrimitive( myDGSEM, iEl, varID, theBackgroundState  )
 ! S/R GetBackgroundStateWithVarID
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl, varID
   REAL(prec), INTENT(out)                 :: theBackgroundState(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)

      CALL myDGSEM % background(iEl) % GetSolutionWithVarID( varID, theBackgroundState )

 END SUBROUTINE GetBackgroundStateWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetBackgroundStateWithVarID_HydrostaticPrimitive( myDGSEM, iEl, varID, theBackgroundState  )
 ! S/R SetBackgroundStateWithVarID
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl, varID
   REAL(prec), INTENT(in)                     :: theBackgroundState(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)

      CALL myDGSEM % background(iEl) % SetSolutionWithVarID( varID, theBackgroundState )

 END SUBROUTINE SetBackgroundStateWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetBackgroundStateAtNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, theBackgroundState  )
 ! S/R GetBackgroundStateAtNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   INTEGER, INTENT(in)                     :: i, j, k
   REAL(prec), INTENT(out)                 :: theBackgroundState(1:myDGSEM % nEq)

      CALL myDGSEM % background(iEl) % GetSolutionAtNode( i, j, k, theBackgroundState )

 END SUBROUTINE GetBackgroundStateAtNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetBackgroundStateAtNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, theBackgroundState  )
 ! S/R SetBackgroundStateAtNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   INTEGER, INTENT(in)                        :: i, j, k
   REAL(prec), INTENT(in)                     :: theBackgroundState(1:myDGSEM % nEq)

      CALL myDGSEM % background(iEl) % SetSolutionAtNode( i, j, k, theBackgroundState )

 END SUBROUTINE SetBackgroundStateAtNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetBackgroundStateAtNodeWithVarID_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, varID, theBackgroundState  )
 ! S/R GetBackgroundState
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   INTEGER, INTENT(in)          :: i, j, k, varID 
   REAL(prec), INTENT(out)      :: theBackgroundState

      CALL myDGSEM % background(iEl) % GetSolutionAtNodeWithVarID( i, j, k, varID, theBackgroundState )

 END SUBROUTINE GetBackgroundStateAtNodeWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetBackgroundStateAtNodeWithVarID_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, varID, theBackgroundState  )
 ! S/R SetBackgroundState
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   INTEGER, INTENT(in)             :: i, j, k, varID 
   REAL(prec), INTENT(in)          :: theBackgroundState

      CALL myDGSEM % background(iEl) % SetSolutionAtNodeWithVarID( i, j, k, varID, theBackgroundState )

 END SUBROUTINE SetBackgroundStateAtNodeWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetBackgroundStateAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, theBackgroundState  )
 ! S/R GetBoundaryBackgroundState
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   INTEGER, INTENT(in)          :: boundary
   REAL(prec), INTENT(out)      :: theBackgroundState(0:myDGSEM % nS, 0:myDGSEM % nP, 1:myDGSEM % nEq)

      CALL myDGSEM % background(iEl) % GetBoundarySolutionAtBoundary( boundary, theBackgroundState )

 END SUBROUTINE GetBackgroundStateAtBoundary_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetBackgroundStateAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, theBackgroundState  )
 ! S/R SetBoundaryBackgroundState
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   INTEGER, INTENT(in)             :: boundary
   REAL(prec), INTENT(in)          :: theBackgroundState(0:myDGSEM % nS, 0:myDGSEM % nP, 1:myDGSEM % nEq)

      CALL myDGSEM % background(iEl) % SetBoundarySolutionAtBoundary( boundary, theBackgroundState )

 END SUBROUTINE SetBackgroundStateAtBoundary_HydrostaticPrimitive
!
!--------------------------------------------------------------------------------------------------!
!                                     Planetary Vorticity                                          !
!--------------------------------------------------------------------------------------------------!
!
 SUBROUTINE GetPlanetaryVorticity_HydrostaticPrimitive( myDGSEM, iEl, fCori  )
 ! S/R GetPlanetaryVorticity
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   REAL(prec), INTENT(out)                 :: fCori(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)

      fCori = myDGSEM % planetaryVorticity(:,:,:,iEl)

 END SUBROUTINE GetPlanetaryVorticity_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetPlanetaryVorticity_HydrostaticPrimitive( myDGSEM, iEl, fCori )
 ! S/R SetPlanetaryVorticity
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   REAL(prec), INTENT(in)                     :: fCori(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)

      myDGSEM % planetaryVorticity(:,:,:,iEl) = fCori

 END SUBROUTINE SetPlanetaryVorticity_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetPlanetaryVorticityAtNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, fCori )
 ! S/R GetPlanetaryVorticityAtNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   INTEGER, INTENT(in)                     :: i, j, k
   REAL(prec), INTENT(out)                 :: fCori

      fCori = myDGSEM % planetaryVorticity(i,j,k,iEl)

 END SUBROUTINE GetPlanetaryVorticityAtNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetPlanetaryVorticityAtNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, fCori  )
 ! S/R SetPlanetaryVorticityAtNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   INTEGER, INTENT(in)                        :: i, j, k
   REAL(prec), INTENT(in)                     :: fCori

      myDGSEM % planetaryVorticity(i,j,k,iEl) = fCori

 END SUBROUTINE SetPlanetaryVorticityAtNode_HydrostaticPrimitive
!
!--------------------------------------------------------------------------------------------------!
!                                          Velocity                                                !
!--------------------------------------------------------------------------------------------------!
!
 SUBROUTINE GetVelocity_HydrostaticPrimitive( myDGSEM, iEl, u, v )
 ! S/R GetVelocity
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   REAL(prec), INTENT(out)                 :: u(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec), INTENT(out)                 :: v(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ)
   
      CALL myDGSEM % sol(iEl) % GetSolutionWithVarID( 1, u )
      CALL myDGSEM % sol(iEl) % GetSolutionWithVarID( 2, v )
      
 END SUBROUTINE GetVelocity_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetVelocity_HydrostaticPrimitive( myDGSEM, iEl, u, v )
 ! S/R SetVelocity
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   REAL(prec), INTENT(in)                     :: u(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec), INTENT(in)                     :: v(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ)

      CALL myDGSEM % sol(iEl) % SetSolutionWithVarID( 1, u )
      CALL myDGSEM % sol(iEl) % SetSolutionWithVarID( 2, v )

 END SUBROUTINE SetVelocity_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetVelocityAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, u, v  )
 ! S/R GetBoundarySolution
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   INTEGER, INTENT(in)                     :: boundary
   REAL(prec), INTENT(out)                 :: u(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec), INTENT(out)                 :: v(0:myDGSEM % nS, 0:myDGSEM % nP)

   
      CALL myDGSEM % sol(iEl) % GetBoundarySolutionAtBoundaryWithVarID( boundary, 1, u )
      CALL myDGSEM % sol(iEl) % GetBoundarySolutionAtBoundaryWithVarID( boundary, 2, v )

      
 END SUBROUTINE GetVelocityAtBoundary_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetVelocityAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, u, v  )
 ! S/R SetVelocityAtBoundary
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   INTEGER, INTENT(in)                        :: boundary
   REAL(prec), INTENT(in)                     :: u(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec), INTENT(in)                     :: v(0:myDGSEM % nS, 0:myDGSEM % nP)
   
      CALL myDGSEM % sol(iEl) % SetBoundarySolutionAtBoundaryWithVarID( boundary, 1, u )
      CALL myDGSEM % sol(iEl) % SetBoundarySolutionAtBoundaryWithVarID( boundary, 2, v )
     
 END SUBROUTINE SetVelocityAtBoundary_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetVelocityAtBoundaryNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, boundary, u, v  )
 ! S/R GetVelocityAtBoundaryNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl, i, j
   INTEGER, INTENT(in)                     :: boundary
   REAL(prec), INTENT(out)                 :: u
   REAL(prec), INTENT(out)                 :: v

   
      CALL myDGSEM % sol(iEl) % GetBoundarySolutionAtBoundaryNodeWithVarID( i, j, boundary, 1, u )
      CALL myDGSEM % sol(iEl) % GetBoundarySolutionAtBoundaryNodeWithVarID( i, j, boundary, 2, v )

      
 END SUBROUTINE GetVelocityAtBoundaryNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetVelocityAtBoundaryNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, boundary, u, v  )
 ! S/R SetVelocityAtBoundaryNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl, i, j
   INTEGER, INTENT(in)                        :: boundary
   REAL(prec), INTENT(in)                     :: u
   REAL(prec), INTENT(in)                     :: v
   
      CALL myDGSEM % sol(iEl) % SetBoundarySolutionAtBoundaryNodeWithVarID( i, j, boundary, 1, u )
      CALL myDGSEM % sol(iEl) % SetBoundarySolutionAtBoundaryNodeWithVarID( i, j, boundary, 2, v )
     
 END SUBROUTINE SetVelocityAtBoundaryNode_HydrostaticPrimitive
!
!--------------------------------------------------------------------------------------------------!
!                                          Buoyancy                                                !
!--------------------------------------------------------------------------------------------------!
!
 SUBROUTINE GetBuoyancy_HydrostaticPrimitive( myDGSEM, iEl, b )
 ! S/R GetBuoyancy
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   REAL(prec), INTENT(out)                 :: b(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ)
   
      CALL myDGSEM % sol(iEl) % GetSolutionWithVarID( bEq, b )
      
 END SUBROUTINE GetBuoyancy_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetBuoyancy_HydrostaticPrimitive( myDGSEM, iEl, b  )
 ! S/R SetBuoyancy
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   REAL(prec), INTENT(in)                     :: b(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ)

      CALL myDGSEM % sol(iEl) % SetSolutionWithVarID( bEq, b )

 END SUBROUTINE SetBuoyancy_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetBuoyancyAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, b  )
 ! S/R GetBuoyancyAtBoundary
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   INTEGER, INTENT(in)                     :: boundary
   REAL(prec), INTENT(out)                 :: b(0:myDGSEM % nS, 0:myDGSEM % nP)
   
      CALL myDGSEM % sol(iEl) % GetBoundarySolutionAtBoundaryWithVarID( boundary, bEq, b )
      
 END SUBROUTINE GetBuoyancyAtBoundary_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetBuoyancyAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, b  )
 ! S/R SetBuoyancyAtBoundary
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   INTEGER, INTENT(in)             :: boundary
   REAL(prec), INTENT(in)          :: b(0:myDGSEM % nS, 0:myDGSEM % nP)
   
      CALL myDGSEM % sol(iEl) % SetBoundarySolutionAtBoundaryWithVarID( boundary, bEq, b )
     
 END SUBROUTINE SetBuoyancyAtBoundary_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetBuoyancyAtBoundaryNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, boundary, b  )
 ! S/R GetBuoyancyAtBoundaryNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl, i, j
   INTEGER, INTENT(in)                     :: boundary
   REAL(prec), INTENT(out)                 :: b

      CALL myDGSEM % sol(iEl) % GetBoundarySolutionAtBoundaryNodeWithVarID( i, j, boundary, bEq, b )
      
 END SUBROUTINE GetBuoyancyAtBoundaryNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetBuoyancyAtBoundaryNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, boundary, b  )
 ! S/R SetBuoyancyAtBoundaryNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl, i, j
   INTEGER, INTENT(in)             :: boundary
   REAL(prec), INTENT(in)          :: b
   
      CALL myDGSEM % sol(iEl) % SetBoundarySolutionAtBoundaryNodeWithVarID( i, j, boundary, bEq, b )
     
 END SUBROUTINE SetBuoyancyAtBoundaryNode_HydrostaticPrimitive
!
!--------------------------------------------------------------------------------------------------!
!                                          Tendency                                                !
!--------------------------------------------------------------------------------------------------!
!
 SUBROUTINE GetPreviousTendency_HydrostaticPrimitive( myDGSEM, iEl, theTend  )
 ! S/R GetPreviousTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   REAL(prec), INTENT(out)      :: theTend(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ, 1:myDGSEM % nEq)
   ! Local
   INTEGER :: iEq
      
      DO iEq = 1, nPrognostic
         CALL myDGSEM % prevsol(iEl) % GetTendencyWithVarID( iEq, theTend(:,:,:,iEq) )
      ENDDO

 END SUBROUTINE GetPreviousTendency_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetPreviousTendency_HydrostaticPrimitive( myDGSEM, iEl, theTend  )
 ! S/R SetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   REAL(prec), INTENT(in)                     :: theTend(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ, 1:nPrognostic)
   ! Local
   INTEGER :: iEq
      
      DO iEq = 1, nPrognostic
         CALL myDGSEM % prevsol(iEl) % SetTendencyWithVarID( iEq, theTend(:,:,:,iEq) )
      ENDDO   

 END SUBROUTINE SetPreviousTendency_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetTendency_HydrostaticPrimitive( myDGSEM, iEl, theTend  )
 ! S/R GetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   REAL(prec), INTENT(out)      :: theTend(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ, 1:myDGSEM % nEq)
   ! Local
   INTEGER :: iEq
      
      DO iEq = 1, nPrognostic
         CALL myDGSEM % sol(iEl) % GetTendencyWithVarID( iEq, theTend(:,:,:,iEq) )
      ENDDO

 END SUBROUTINE GetTendency_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetTendency_HydrostaticPrimitive( myDGSEM, iEl, theTend  )
 ! S/R SetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   REAL(prec), INTENT(in)                     :: theTend(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ, 1:nPrognostic)
   ! Local
   INTEGER :: iEq
      
      DO iEq = 1, nPrognostic
         CALL myDGSEM % sol(iEl) % SetTendencyWithVarID( iEq, theTend(:,:,:,iEq) )
      ENDDO   

 END SUBROUTINE SetTendency_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetTendencyAtNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, theTend  )
 ! S/R GetTendencyAtNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   INTEGER, INTENT(in)          :: i, j, k 
   REAL(prec), INTENT(out)      :: theTend(1:nPrognostic)
   ! Local
   INTEGER :: iEq

      DO iEq = 1, nPrognostic
         CALL myDGSEM % sol(iEl) % GetTendencyAtNodeWithVarID( i, j, k, iEq, theTend(iEq) )
      ENDDO

 END SUBROUTINE GetTendencyAtNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetTendencyAtNode_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, theTend  )
 ! S/R SetTendencyAtNode
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   INTEGER, INTENT(in)                        :: i, j, k 
   REAL(prec), INTENT(in)                     :: theTend(1:nPrognostic)
   ! LOCAL
   INTEGER :: iEq
      
      DO iEq = 1, nPrognostic
         CALL myDGSEM % sol(iEl) % SetTendencyAtNodeWithVarID( i, j, k, iEq, theTend(iEq) )
      ENDDO

 END SUBROUTINE SetTendencyAtNode_HydrostaticPrimitive
!
!
!
SUBROUTINE GetTendencyWithVarID_HydrostaticPrimitive( myDGSEM, iEl, varID, theTend  )
 ! S/R GetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   INTEGER, INTENT(in)          :: varID 
   REAL(prec), INTENT(out)      :: theTend(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ)

      CALL myDGSEM % sol(iEl) % GetTendencyWithVarID( varID, theTend )

 END SUBROUTINE GetTendencyWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetTendencyWithVarID_HydrostaticPrimitive( myDGSEM, iEl, varID, theTend  )
 ! S/R SetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   INTEGER, INTENT(in)             :: varID 
   REAL(prec), INTENT(in)          :: theTend(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ)

      CALL myDGSEM % sol(iEl) % SetTendencyWithVarID( varID, theTend )

 END SUBROUTINE SetTendencyWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetTendencyAtNodeWithVarID_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, varID, theTend  )
 ! S/R GetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)          :: iEl
   INTEGER, INTENT(in)          :: i, j, k, varID 
   REAL(prec), INTENT(out)      :: theTend

      CALL myDGSEM % sol(iEl) % GetTendencyAtNodeWithVarID( i, j, k, varID, theTend )

 END SUBROUTINE GetTendencyAtNodeWithVarID_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetTendencyAtNodeWithVarID_HydrostaticPrimitive( myDGSEM, iEl, i, j, k, varID, theTend  )
 ! S/R SetTendency
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   INTEGER, INTENT(in)             :: i, j, k, varID 
   REAL(prec), INTENT(in)          :: theTend

      CALL myDGSEM % sol(iEl) % SetTendencyAtNodeWithVarID( i, j, k, varID, theTend )

 END SUBROUTINE SetTendencyAtNodeWithVarID_HydrostaticPrimitive
!
!--------------------------------------------------------------------------------------------------!
!                                            Flux                                                  !
!--------------------------------------------------------------------------------------------------!
!
 SUBROUTINE GetFluxAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, theFlux  )
 ! S/R GetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   INTEGER, INTENT(in)                     :: boundary
   REAL(prec), INTENT(out)                 :: theFlux(0:myDGSEM % nS, 0:myDGSEM % nP, 1:nPrognostic)
   ! Local
   INTEGER :: iEq
    
      DO iEq = 1, nPrognostic
         CALL myDGSEM % sol(iEl) % GetBoundaryFluxAtBoundaryWithVarID( boundary, iEq, theFlux(:,:,iEq) )
      ENDDO

 END SUBROUTINE GetFluxAtBoundary_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetFluxAtBoundary_HydrostaticPrimitive( myDGSEM, iEl, boundary, theFlux  )
 ! S/R SetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   INTEGER, INTENT(in)                        :: boundary
   REAL(prec), INTENT(in)                     :: theFlux(0:myDGSEM % nS, 0:myDGSEM % nP, 1:nPrognostic)
   ! Local
   INTEGER :: iEq
    
      DO iEq = 1, nPrognostic
         CALL myDGSEM % sol(iEl) % SetBoundaryFluxAtBoundaryWithVarID( boundary, iEq, theFlux(:,:,iEq) )
      ENDDO

 END SUBROUTINE SetFluxAtBoundary_HydrostaticPrimitive
!
!
!
 SUBROUTINE GetFluxAtBoundaryNode_HydrostaticPrimitive( myDGSEM, iEl, boundary, i, j, theFlux  )
 ! S/R GetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)                     :: iEl
   INTEGER, INTENT(in)                     :: boundary, i, j
   REAL(prec), INTENT(out)                 :: theFlux(1:nPrognostic)
   ! Local
   INTEGER :: iEq
    
      DO iEq = 1, nPrognostic
         CALL myDGSEM % sol(iEl) % GetBoundaryFluxAtBoundaryNodeWithVarID( i, j, boundary, iEq, theFlux(iEq) )
      ENDDO

 END SUBROUTINE GetFluxAtBoundaryNode_HydrostaticPrimitive
!
!
!
 SUBROUTINE SetFluxAtBoundaryNode_HydrostaticPrimitive( myDGSEM, iEl, boundary, i, j, theFlux  )
 ! S/R SetBoundaryFlux
 !  
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   INTEGER, INTENT(in)                        :: boundary, i, j
   REAL(prec), INTENT(in)                     :: theFlux(1:nPrognostic)
   ! Local
   INTEGER :: iEq
    
      DO iEq = 1, nPrognostic
         CALL myDGSEM % sol(iEl) % SetBoundaryFluxAtBoundaryNodeWithVarID( i, j, boundary, iEq, theFlux(iEq) )
      ENDDO

 END SUBROUTINE SetFluxAtBoundaryNode_HydrostaticPrimitive
!
!
!==================================================================================================!
!--------------------------------- Type Specific Routines -----------------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE CalculateSolutionAtBoundaries_HydrostaticPrimitive( myDGSEM, iEl )
 ! S/R CalculateSolutionAtBoundaries
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                        :: iEl
   
      CALL myDGSEM % sol(iEl) % CalculateSolutionAtBoundaries( myDGSEM % dgStorage )
      
 END SUBROUTINE CalculateSolutionAtBoundaries_HydrostaticPrimitive
!
!
!
 SUBROUTINE ForwardStepAB2_HydrostaticPrimitive( myDGSEM, tn )
 ! S/R ForwardStepAB2( 2nd Order Adams Bashforth )
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   REAL(prec), INTENT(in)                     :: tn
   ! LOCAL
   REAL(prec) :: G(0:myDGSEM % nS, &
                   0:myDGSEM % nP, &
                   0:myDGSEM % nQ, &
                   1:nPrognostic )
   REAL(prec) :: dSdt(0:myDGSEM % nS, &
                      0:myDGSEM % nP, &
                      0:myDGSEM % nQ, &
                      1:nPrognostic )
   REAL(prec) :: dt
   INTEGER    :: m, iEl

      dt = myDGSEM % params % dt
      G2D = ZERO

      CALL myDGSEM % ForwardStepBarotropic( tn, dt )

      ! Calculate the tendency
      CALL myDGSEM % GlobalTimeDerivative( tm, m )
        
      DO iEl = 1, myDGSEM % mesh % nElems ! Loop over all of the elements

         CALL myDGSEM % GetTendency( iEl, dSdt )
         CALL myDGSEM % GetPreviousTendency( iEl, G )
         G = HALF*( 3.0_prec*dSdt - G )

         myDGSEM % sol(iEl) % solution(:,:,:,1:nPrognostic) = myDGSEM % sol(iEl) % solution(:,:,:,1:nPrognostic) +&
                                                              dt*G
         CALL myDGSEM % SetPreviousTendency( iEl, dSdt )
      ENDDO ! iEl, loop over all of the elements
 
      ! Correct the velocity
      CALL myDGSEM % AdjustVelocity( )
         
   
   
       
 END SUBROUTINE ForwardStepAB2_HydrostaticPrimitive
!
!
!
 SUBROUTINE GlobalTimeDerivative_HydrostaticPrimitive( myDGSEM, tn, m ) 
 ! S/R GlobalTimeDerivative_HydrostaticPrimitive
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   REAL(prec), INTENT(in)                     :: tn
   INTEGER, INTENT(in)                        :: m
   ! Local
   INTEGER :: iEl, iFace, tID


!$OMP PARALLEL


!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( csabTimer )
      DO iEl = 1, myDGSEM % mesh % nElems
         CALL myDGSEM % CalculateSolutionAtBoundaries( iEl ) 
      ENDDO 
!$OMP END DO 
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( csabTimer )


!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( diagpTimer )
      DO iEl = 1, myDGSEM % mesh % nHElems
      !   CALL myDGSEM % DiagnoseP( iEl )
      ! Add the barotropic pressure to the baroclinic pressure
      ENDDO
!$OMP END DO 
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( diagpTimer )
      

!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( diagwTimer )
      DO iEl = 1, myDGSEM % mesh % nHElems
         CALL myDGSEM % DiagnoseW( iEl )
      ENDDO
!$OMP END DO 
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( diagwTimer )

!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( csabTimer )
      DO iEl = 1, myDGSEM % mesh % nElems
         CALL myDGSEM % CalculateSolutionAtBoundaries( iEl ) 
      ENDDO 
!$OMP END DO 
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( csabTimer )

!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( efluxTimer )
      DO iFace = 1, myDGSEM % mesh % nFaces
         CALL myDGSEM % EdgeFlux( iFace, tn )
      ENDDO
!$OMP END DO
!$OMP FLUSH( myDGSEM ) 
      CALL myDGSEM % clocks % StopThisTimer( efluxTimer )


!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( mtdTimer )
      DO iEl = 1, myDGSEM % mesh % nElems
         CALL myDGSEM % MappedTimeDerivative( iEl, tn )
      ENDDO
!$OMP END DO
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( mtdTimer )

!$OMP END PARALLEL

 
 END SUBROUTINE GlobalTimeDerivative_HydrostaticPrimitive
!
!
!
SUBROUTINE CalculateBaroclinicFields_HydrostaticPrimitive( myDGSEM, tn ) 
 ! S/R CalculateBaroclinicFields_HydrostaticPrimitive
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   REAL(prec), INTENT(in)                     :: tn
   ! Local
   INTEGER :: iEl, iFace, tID


!$OMP PARALLEL


!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( diagpTimer )
      DO iEl = 1, myDGSEM % mesh % nHElems
         CALL myDGSEM % DiagnoseP( iEl )
      ENDDO
!$OMP END DO 
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( diagpTimer )
      

!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( diagTTimer )
      DO iEl = 1, myDGSEM % mesh % nHElems
         CALL myDGSEM % DiagnoseTransport( iEl )
      ENDDO
!$OMP END DO 
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( diagTTimer )

!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( cbvTimer )
      DO iEl = 1, myDGSEM % mesh % nHElems
         CALL myDGSEM % CalculateBaroclinicVelocity( iEl )
      ENDDO
!$OMP END DO 
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( cbvTimer )


!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( csabTimer )
      DO iEl = 1, myDGSEM % mesh % nElems
         CALL myDGSEM % baroclinic(iEl) % CalculateSolutionAtBoundaries( myDGSEM % dgStorage ) 
      ENDDO 
!$OMP END DO 
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( csabTimer )

!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( befluxTimer )
      DO iFace = 1, myDGSEM % mesh % nFaces
         CALL myDGSEM % BaroclinicEdgeFlux( iFace, tn )
      ENDDO
!$OMP END DO
!$OMP FLUSH( myDGSEM ) 
      CALL myDGSEM % clocks % StopThisTimer( befluxTimer )


!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( btdTimer )
      DO iEl = 1, myDGSEM % mesh % nElems
         CALL myDGSEM % BaroclinicTendency( iEl, tn )
      ENDDO
!$OMP END DO
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( btdTimer )

!$OMP DO
      CALL myDGSEM % clocks % StartThisTimer( csrcTimer )
      DO iEl = 1, myDGSEM % mesh % nHElems
         CALL myDGSEM % CalculateSourceForBarotropic( iEl, tn )
      ENDDO
!$OMP END DO
!$OMP FLUSH( myDGSEM )
      CALL myDGSEM % clocks % StopThisTimer( csrcTimer )


!$OMP END PARALLEL

 
 END SUBROUTINE CalculateBaroclinicFields_HydrostaticPrimitive
!
!
!
 SUBROUTINE CalculateSourceForBarotropic_HydrostaticPrimitive( myDGSEM, iEl )
 !
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iEl 
   ! LOCAL
   INTEGER    :: iS, iP, iQ, iLayer, nS, nLayers, elID, k, M
   REAL(prec) :: xiK
   REAL(prec) :: ztop(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: zbot(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: x1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: y1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: x(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ) 
   REAL(prec) :: y(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec) :: z(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ) 
   REAL(prec) :: tend(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ,1:nHPEq), 
   REAL(prec) :: locU(0:myDGSEM % nQ), locV(0:myDGSEM % nQ)
   REAL(prec) :: uu(0:myDGSEM % nS, 0:myDGSEM % nP), vv(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: ui(0:myDGSEM % nS, 0:myDGSEM % nP), uip1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: intnodes(0:myDGSEM % intStorage % nS), qw(0:myDGSEM % intStorage % nS)
   REAL(prec) :: xi(0:myDGSEM % nS), xiI, xiIp1, lagBottom(0:myDGSEM % nQ)
   REAL(prec) :: temp(0:myDGSEM % nS)
   REAL(prec) :: du(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: dv(0:myDGSEM % nS, 0:myDGSEM % nP)

      nS      = myDGSEM % nS
      nLayers = myDGSEM % mesh % nLayers
      M       = myDGSEM % intStorage % nS

      CALL myDGSEM % dgStorage % GetNodes( xi, locB, temp )
      CALL myDGSEM % dgStorage % GetBottomInterpolants( lagBottom )
      CALL myDGSEM % intStorage % GetNodes( intnodes )
      CALL myDGSEM % intStorage % GetQuadratureWeights( qw )
      elID = myDGSEM % mesh % stackMap(iEl,nLayers)
      upi  = ZERO
      vpi  = ZERO 

      DO iLayer = nLayers,1, -1

         elID = myDGSEM % mesh % stackMap(iEl,iLayer)
         CALL myDGSEM % baroclinic(elID) % GetTendency( tend )
         CALL myDGSEM % mesh % GetPositions( elID, x, y, z )
         CALL myDGSEM % mesh % GetBoundaryLocation( elID, x1, y1, ztop, Top )
         CALL myDGSEM % mesh % GetBoundaryLocation( elID, x1, y1, zbot, Bottom )

         xiI = ONE
         DO iQ = nS,0,-1
            
            xiIp1 = xi(iQ)
            du    = ZERO
            dv    = ZERO

            DO k = 0, M 
               xiK = HALF*(xiIp1-xiI)*( intnodes(k) + ONE ) + xiI

               DO iP = 0, nS
                  DO iS = 0, nS
                     locU = tend(iS,iP,0:nS,1)
                     locV = tend(iS,iP,0:nS,2)
                     uu(iS,iP) = myDGSEM % intStorage % interp % EvaluateInterpolant( xiK, locU )
                     vv(iS,iP) = myDGSEM % intStorage % interp % EvaluateInterpolant( xiK, locV )
                  ENDDO
               ENDDO

               du = du + uu*qw(k)
               dv = dv + vv*qw(k)

            ENDDO
               
            uip1 = ui + du*HALF*(ztop-zbot)*HALF*(xiIp1-xiI)
            vip1 = vi + du*HALF*(ztop-zbot)*HALF*(xiIp1-xiI)
            x(:,:,iQ) = uip1
            y(:,:,iQ) = vip1
            upi = uip1
            vpi = vip1
            xiI = xiIp1

         ENDDO

         DO iP = 0, nS
            DO iS = 0, nS
               temp = x
               uhpi(iS,iP) = DOT_PRODUCT( lagBottom, temp )
               temp = y
               vhpi(iS,iP) = DOT_PRODUCT( lagBottom, temp )
            ENDDO
         ENDDO 

      ENDDO

      myDGSEM % barotropic % baroclinicSource(:,:,iEl,1) = -uhpi
      myDGSEM % barotropic % baroclinicSource(:,:,iEl,2) = -vhpi

 END SUBROUTINE CalculateSourceForBarotropic_HydrostaticPrimitive
!
!
! 
 SUBROUTINE AdjustVelocity_HydrostaticPrimitive( myDGSEM, iEl, dt, dndx, dndy )
 !
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iEl
   REAL(prec), INTENT(in)                       :: dt
   REAL(prec), INTENT(in)                       :: dndx(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec), INTENT(in)                       :: dndy(0:myDGSEM % nS, 0:myDGSEM % nP)
   ! LOCAL
   INTEGER    :: eID, iLayer, k, nLayers, nQ
   REAL(prec) :: g
 
      nLayers = myDGSEM % mesh % nLayers
      nQ      = myDGSEM % nQ
      g       = myDGSEM % params % g
 
      DO iLayer = 1, nLayers

         eID = myDGSEM % mesh % stackMap(iEl,iLayer)

         DO k = 0, nQ

            myDGSEM % sol(eID) % solution(:,:,k,1) = myDGSEM % sol(eID) % solution(:,:,k,1) - &
                                                     g*dt*dndx

            myDGSEM % sol(eID) % solution(:,:,k,2) = myDGSEM % sol(eID) % solution(:,:,k,2) - &
                                                     g*dt*dndy

         ENDDO
      ENDDO


 END SUBROUTINE AdjustVelocity_HydrostaticPrimitive
!
!
!
 SUBROUTINE DiagnoseP_HydrostaticPrimitive( myDGSEM, iEl )
 !
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iEl 
   ! LOCAL
   INTEGER    :: iS, iP, iQ, iLayer, nS, nLayers, elID, k, M
   REAL(prec) :: xiK
   REAL(prec) :: ztop(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: zbot(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: x1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: y1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: x(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ) 
   REAL(prec) :: y(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec) :: z(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ) 
   REAL(prec) :: b(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ), locB(0:myDGSEM % nQ)
   REAL(prec) :: bb(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: hpi(0:myDGSEM % nS, 0:myDGSEM % nP), hpip1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: intnodes(0:myDGSEM % intStorage % nS), qw(0:myDGSEM % intStorage % nS)
   REAL(prec) :: xi(0:myDGSEM % nS), xiI, xiIp1, lagBottom(0:myDGSEM % nQ)
   REAL(prec) :: temp(0:myDGSEM % nS)
   REAL(prec) :: dp(0:myDGSEM % nS, 0:myDGSEM % nP)

      nS      = myDGSEM % nS
      nLayers = myDGSEM % mesh % nLayers
      M       = myDGSEM % intStorage % nS

      CALL myDGSEM % dgStorage % GetNodes( xi, locB, temp )
      CALL myDGSEM % dgStorage % GetBottomInterpolants( lagBottom )
      CALL myDGSEM % intStorage % GetNodes( intnodes )
      CALL myDGSEM % intStorage % GetQuadratureWeights( qw )
      elID = myDGSEM % mesh % stackMap(iEl,nLayers)
      hpi  = ZERO
 
      DO iLayer = nLayers,1, -1

         elID = myDGSEM % mesh % stackMap(iEl,iLayer)
         CALL myDGSEM % GetBuoyancy( elID, b )
         CALL myDGSEM % mesh % GetPositions( elID, x, y, z )
         CALL myDGSEM % mesh % GetBoundaryLocation( elID, x1, y1, ztop, Top )
         CALL myDGSEM % mesh % GetBoundaryLocation( elID, x1, y1, zbot, Bottom )

         xiI = ONE
         DO iQ = nS,0,-1
            
            xiIp1 = xi(iQ)
            dp   = ZERO

            DO k = 0, M 
               xiK = HALF*(xiIp1-xiI)*( intnodes(k) + ONE ) + xiI

               DO iP = 0, nS
                  DO iS = 0, nS
                     locB = b(iS,iP,0:nS)
                     bb(iS,iP) = myDGSEM % intStorage % interp % EvaluateInterpolant( xiK, locB )
                  ENDDO
               ENDDO

               dp = dp + bb*qw(k)

            ENDDO
               
            hpip1 = hpi + dp*HALF*(ztop-zbot)*HALF*(xiIp1-xiI)
            myDGSEM % sol(elID) % solution(0:nS,0:nS,iQ,pEq) = hpip1

            hpi = hpip1
            xiI = xiIp1

         ENDDO

         DO iP = 0, nS
            DO iS = 0, nS
               temp = myDGSEM % sol(elID) % solution(iS,iP,0:nS,pEq)
               hpi(iS,iP) = DOT_PRODUCT( lagBottom, temp )
            ENDDO
         ENDDO 

      ENDDO

                  
 END SUBROUTINE DiagnoseP_HydrostaticPrimitive
!
!
! 
 SUBROUTINE DiagnoseW_HydrostaticPrimitive( myDGSEM, iEl )
 !
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iEl 
   ! LOCAL
   INTEGER    :: iS, iP, iQ, iLayer, nS, nLayers, elID, k, M
   REAL(prec) :: xiK
   REAL(prec) :: ztop(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: zbot(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: x1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: y1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: x(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ) 
   REAL(prec) :: y(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec) :: z(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ) 
   REAL(prec) :: divU(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ), locDU(0:myDGSEM % nQ)
   REAL(prec) :: du(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: wi(0:myDGSEM % nS, 0:myDGSEM % nP), wip1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: intnodes(0:myDGSEM % intStorage % nS), qw(0:myDGSEM % intStorage % nS)
   REAL(prec) :: xi(0:myDGSEM % nS), xiI, xiIp1, lagTop(0:myDGSEM % nQ)
   REAL(prec) :: temp(0:myDGSEM % nS)
   REAL(prec) :: dw(0:myDGSEM % nS, 0:myDGSEM % nP)


      nS      = myDGSEM % nS
      nLayers = myDGSEM % mesh % nLayers
      M       = myDGSEM % intStorage % nS

      CALL myDGSEM % dgStorage % GetNodes( xi, locDU, temp )
      CALL myDGSEM % dgStorage % GetTopInterpolants( lagTop )
      CALL myDGSEM % intStorage % GetNodes( intnodes )
      CALL myDGSEM % intStorage % GetQuadratureWeights( qw )

      ! Set the bottom vertical velocity to the up-slope projection of the lateral flow
      CALL myDGSEM % CalculateBottomVerticalVelocity( iEl )
      wi  = myDGSEM % bottomW(0:nS,0:nS,iEl)
 
      DO iLayer = 1, nLayers

         elID = myDGSEM % mesh % stackMap(iEl,iLayer)
         divU = myDGSEM % divU(0:nS,0:nS,0:nS,elID)
         CALL myDGSEM % mesh % GetPositions( elID, x, y, z )
         CALL myDGSEM % mesh % GetBoundaryLocation( elID, x1, y1, ztop, Top )
         CALL myDGSEM % mesh % GetBoundaryLocation( elID, x1, y1, zbot, Bottom )

         xiI = -ONE
         DO iQ = 0, nS
            
            xiIp1 = xi(iQ)
            dw   = ZERO

            DO k = 0, M 
               xiK = HALF*(xiIp1-xiI)*( intnodes(k) + ONE ) + xiI

               DO iP = 0, nS
                  DO iS = 0, nS
                     locDU = divU(iS,iP,0:nS)
                     du(iS,iP) = myDGSEM % intStorage % interp % EvaluateInterpolant( xiK, locDU )
                  ENDDO
               ENDDO
               !w_z = -( u_x + v_y )
               dw = dw - du*qw(k)

            ENDDO
               
            wip1 = wi + dw*HALF*(ztop-zbot)*HALF*(xiIp1-xiI)
            myDGSEM % sol(elID) % solution(0:nS,0:nS,iQ,wEq) = wip1

            wi  = wip1
            xiI = xiIp1

         ENDDO

         DO iP = 0, nS
            DO iS = 0, nS
               temp = myDGSEM % sol(elID) % solution(iS,iP,0:nS,wEq)
               wi(iS,iP) = DOT_PRODUCT( lagTop, temp )
            ENDDO
         ENDDO 

      ENDDO

  
 END SUBROUTINE DiagnoseW_HydrostaticPrimitive
!
!
!
 SUBROUTINE CalculateBottomVerticalVelocity_HydrostaticPrimitive( myDGSEM, iEl )
 ! S/R CalculateBottomVerticalVelocity
 !
 !   This routine takes in the LATERAL element id, and fills in the bottom cross isobath flow and
 !   bottom buoyancy field.
 ! =============================================================================================== !
 ! DECLARATIONS
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iEl
   ! LOCAL
   INTEGER :: iS, iP, nS, nP, elID
   REAL(prec) :: ub(0:myDGSEM % nS, 0:myDGSEM % nS), vb(0:myDGSEM % nS, 0:myDGSEM % nS)
   REAL(prec) :: nHat(1:nDim), nHatLength

      nS = myDGSEM % nS
      nP = myDGSEM % nP

      elID = myDGSEM % mesh % stackMap(iEl,1) ! Get the element ID in this stack at the bottom

      CALL myDGSEM % GetVelocityAtBoundary( elID, bottom, ub, vb )

      DO iP = 0, nP
         DO iS = 0, nS
            ! Get the "bottom" flux at iS,iP
            CALL myDGSEM % mesh % GetBoundaryNormalAtNode( elID, nHat, nHatLength, iS, iP, bottom )
            myDGSEM % bottomW(iS,iP,iEl)  = -( ub(iS,iP)*nHat(1) + vb(iS,iP)*nHat(2) )/nHat(3)
         ENDDO
      ENDDO
            
 END SUBROUTINE CalculateBottomVerticalVelocity_HydrostaticPrimitive
!
!
!
 SUBROUTINE DiagnoseTransport_HydrostaticPrimitive( myDGSEM, iEl )
 !
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iEl 
   ! LOCAL
   INTEGER    :: iS, iP, iQ, iLayer, nS, nLayers, elID, k, M
   REAL(prec) :: xiK
   REAL(prec) :: ztop(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: zbot(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: x1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: y1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: ucell(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ) 
   REAL(prec) :: vcell(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec) :: u(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ), locU(0:myDGSEM % nQ)
   REAL(prec) :: v(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ), locV(0:myDGSEM % nQ)
   REAL(prec) :: uu(0:myDGSEM % nS, 0:myDGSEM % nP), vv(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: ui(0:myDGSEM % nS, 0:myDGSEM % nP), uip1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: vi(0:myDGSEM % nS, 0:myDGSEM % nP), vip1(0:myDGSEM % nS, 0:myDGSEM % nP)
   REAL(prec) :: intnodes(0:myDGSEM % intStorage % nS), qw(0:myDGSEM % intStorage % nS)
   REAL(prec) :: xi(0:myDGSEM % nS), xiI, xiIp1, lagTop(0:myDGSEM % nQ)
   REAL(prec) :: temp(0:myDGSEM % nS)
   REAL(prec) :: dw(0:myDGSEM % nS, 0:myDGSEM % nP)


      nS      = myDGSEM % nS
      nLayers = myDGSEM % mesh % nLayers
      M       = myDGSEM % intStorage % nS

      CALL myDGSEM % dgStorage % GetNodes( xi, locDU, temp )
      CALL myDGSEM % dgStorage % GetTopInterpolants( lagTop )
      CALL myDGSEM % intStorage % GetNodes( intnodes )
      CALL myDGSEM % intStorage % GetQuadratureWeights( qw )

      ! Set the bottom vertical velocity to the up-slope projection of the lateral flow
      ui = ZERO
      vi = ZERO
 
      DO iLayer = 1, nLayers

         elID = myDGSEM % mesh % stackMap(iEl,iLayer)
         CALL myDGSEM % GetVelocity( elID, u, v )

!         CALL myDGSEM % mesh % GetPositions( elID, x, y, z )
         CALL myDGSEM % mesh % GetBoundaryLocation( elID, x1, y1, ztop, Top )
         CALL myDGSEM % mesh % GetBoundaryLocation( elID, x1, y1, zbot, Bottom )

         xiI = -ONE
         DO iQ = 0, nS
            
            xiIp1 = xi(iQ)
            du    = ZERO
            dv    = ZERO

            DO k = 0, M 
               xiK = HALF*(xiIp1-xiI)*( intnodes(k) + ONE ) + xiI

               DO iP = 0, nS
                  DO iS = 0, nS
                     locU = u(iS,iP,0:nS)
                     uu(iS,iP) = myDGSEM % intStorage % interp % EvaluateInterpolant( xiK, locU )
                     locV = v(iS,iP,0:nS)
                     vv(iS,iP) = myDGSEM % intStorage % interp % EvaluateInterpolant( xiK, locv )
                  ENDDO
               ENDDO
               
               du = du + uu*qw(k)
               du = dv + uu*qw(k)

            ENDDO
               
            uip1 = ui + du*HALF*(ztop-zbot)*HALF*(xiIp1-xiI)
            vip1 = vi + dv*HALF*(ztop-zbot)*HALF*(xiIp1-xiI)

            ucell(:,:,iQ) = uip1
            vcell(:,:,iQ) = vip1

            xiI = xiIp1

         ENDDO

         DO iP = 0, nS
            DO iS = 0, nS
               temp = ucell(iS,iP,0:nS)
               ui(iS,iP) = DOT_PRODUCT( lagTop, temp )
               temp = vcell(iS,iP,0:nS)
               vi(iS,iP) = DOT_PRODUCT( lagTop, temp )
            ENDDO
         ENDDO 

      ENDDO

      myDGSEM % U(0:nS,0:nS,iEl) = ui
      myDGSEM % V(0:nS,0:nS,iEl) = vi
  
 END SUBROUTINE DiagnoseTransport_HydrostaticPrimitive
!
!
!
SUBROUTINE CalculateBaroclinicVelocity_HydrostaticPrimitive( myDGSEM, iEl )
 !
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iEl 
   ! LOCAL
   INTEGER    :: iS, iP, iQ, iLayer, nS, nLayers, elID, k, M
   REAL(prec) :: u(0:myDGSEM % nS, 0:myDGSEM % nS, 0:myDGSEM % nS)
   REAL(prec) :: v(0:myDGSEM % nS, 0:myDGSEM % nS, 0:myDGSEM % nS)
   REAL(prec) :: h(0:myDGSEM % nS, 0:myDGSEM % nS, 1:3)

      nS      = myDGSEM % nS
      nLayers = myDGSEM % mesh % nLayers
      M       = myDGSEM % intStorage % nS
 
      DO iLayer = 1, nLayers

         elID = myDGSEM % mesh % stackMap(iEl,iLayer)
         CALL myDGSEM % GetVelocity( elID, u, v )
         CALL myDGSEM % barotropic % GetBathymetry( iEl, h )
         
         DO iQ = 0, nS
            myDGSEM % baroclinic(elID) % solution(:,:,iQ,1) = u(:,:,iQ) - myDGSEM % U(:,:,iEl)/h(:,:,1)
            myDGSEM % baroclinic(elID) % solution(:,:,iQ,1) = v(:,:,iQ) - myDGSEM % V(:,:,iEl)/h(:,:,1) 
         ENDDO

      ENDDO


  
 END SUBROUTINE CalculateBaroclinicVelocity_HydrostaticPrimitive
!
!
!
 SUBROUTINE EdgeFlux_HydrostaticPrimitive( myDGSEM, iFace, tn )
 ! S/R EdgeFlux
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iFace  
   REAL(prec), INTENT(in)                       :: tn
   ! Local
   INTEGER :: e1, s1, e2, s2, nS, nP, nQ
   INTEGER :: iStart, jStart, iInc, jInc, swapDim
   INTEGER :: i, j, k, l
   REAL(prec) :: flux(1:nPrognostic)
   REAL(prec) :: inState(0:myDGSEM % nS,0:myDGSEM % nP, 1:nHPEq)
   REAL(prec) :: exState(0:myDGSEM % nS,0:myDGSEM % nP, 1:nHPEq)
   REAL(prec) :: bgState(0:myDGSEM % nS,0:myDGSEM % nP, 1:nHPEq)
   REAL(prec) :: inS(1:nHPEq), outS(1:nHPEq), bgS(1:nHPEq)
   REAL(prec) :: x, y, z
   REAL(prec) :: nHat(1:nDim), nHatLength
    

      CALL myDGSEM % dgStorage % GetNumberOfNodes( nS, nP, nQ )
      
      CALL myDGSEM % mesh % GetFacePrimaryElementID( iFace, e1 )
      CALL myDGSEM % mesh % GetFacePrimaryElementSide( iFace, s1 )
      CALL myDGSEM % mesh % GetFaceSecondaryElementID( iFace, e2 )
      CALL myDGSEM % mesh % GetFaceSecondaryElementSide( iFace, s2 )
      
      s2 = ABS(s2)

      CALL myDGSEM % mesh % GetFaceStart( iFace, iStart, jStart )
      CALL myDGSEM % mesh % GetFaceIncrement( iFace, iInc, jInc )
      CALL myDGSEM % mesh % GetSwapDimensions( iFace, swapDim )

      CALL myDGSEM % GetSolutionAtBoundary( e1, s1, inState )
      CALL myDGSEM % GetBackgroundStateAtBoundary( e1, s1, bgState )

      IF( e2 > 0 )then ! this is an interior edge
      
         
         CALL myDGSEM % GetSolutionAtBoundary( e2, s2, exState )
        
         k = (iStart-iInc)*(1-swapDim) + (jStart-jInc)*(swapDim)
         l = (iStart-iInc)*(swapDim) + (jStart-jInc)*(1-swapDim)
         
         DO j = 0, nS ! Loop over the nodes
         
            k = (k + (jInc)*(swapDim))*(swapDim) + (iStart-iInc)*(1-swapDim)
            l = (l + (jInc)*(1-swapDim))*(1-swapDim) + (iStart-iInc)*(swapDim)
            
            DO i = 0, nP
               k = k + (iInc)*(1-swapDim)
               l = l + (iInc)*(swapDim)
              
               CALL myDGSEM % mesh % GetBoundaryNormalAtNode( e1, nHat, nHatLength, i, j, s1 ) ! Get nHat

               inS  = inState(i,j,1:nHPEq)
               outS = exState(k,l,1:nHPEq)
               bgS  = bgState(i,j,1:nHPEq)
               flux = RiemannSolver( inS, outS, bgS, nHat )*nHatLength

               ! Store the flux for the elements which share this edge
               CALL myDGSEM % SetFluxAtBoundaryNode( e1, s1, i, j, flux )
               CALL myDGSEM % SetFluxAtBoundaryNode( e2, s2, k, l, -flux )


            ENDDO ! i, 
         ENDDO ! j, loop over the nodes
         
      ELSE ! this edge is a boundary edge

         DO j = 0, nS ! loop over the nodes
            DO i = 0, nP
               
               CALL myDGSEM % mesh % GetBoundaryNormalAtNode( e1, nHat, nHatLength, i, j, s1 ) ! Get nHat
            
               ! Get the boundary point locations
               CALL myDGSEM % mesh % GetBoundaryLocationAtNode( e1, x, y, z, i, j, s1 )

               ! Calculate the external state
               inS = inState(i,j,1:nHPEq)
               outS = GetExternalState( x, y, z, tn, nHat, e2, inS )
             !  outS = exState(i,j,1:nHPEq)
               bgS  = bgState(i,j,1:nHPEq)
               flux =  RiemannSolver( inS, outS, bgS, nHat )*nHatLength
 
               CALL myDGSEM % SetFluxAtBoundaryNode( e1, s1, i, j, flux )

            ENDDO 
         ENDDO ! j, loop over the nodes on this edge

      ENDIF ! Choosing the edge type
 
 END SUBROUTINE EdgeFlux_HydrostaticPrimitive
!
!
!
 SUBROUTINE MappedTimeDerivative_HydrostaticPrimitive( myDGSEM, iEl, tn ) 
 ! S/R MappedTimeDerivative_HydrostaticPrimitive
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   REAL(prec), INTENT(in)          :: tn
   ! LOCAL
   REAL(prec) :: dxds, dxdp, dxdq, dyds, dydp, dydq, dzds, dzdp, dzdq
   REAL(prec) :: J, x, y, z
   REAL(prec) :: xF(1:nPrognostic), yF(1:nPrognostic), zF(1:nPrognostic)
   REAL(prec) :: sol(1:nHPEq), bsol(1:nHPEq)
   REAL(prec) :: contFlux(0:myDGSEM % nS,1:nPrognostic)
   REAL(prec) :: contFluxDer(0:myDGSEM % nS,1:nPrognostic)
   REAL(prec) :: tend(0:myDGSEM % nS,0:myDGSEM % nP,0:myDGSEM % nQ,1:nPrognostic)
   REAL(prec) :: dMatX(0:myDGSEM % nS,0:myDGSEM % nS)
   REAL(prec) :: dMatY(0:myDGSEM % nP,0:myDGSEM % nP)
   REAL(prec) :: dMatZ(0:myDGSEM % nQ,0:myDGSEM % nQ)
   REAL(prec) :: qWeightX(0:myDGSEM % nS)
   REAL(prec) :: qWeightY(0:myDGSEM % nP)
   REAL(prec) :: qWeightZ(0:myDGSEM % nQ)
   REAL(prec) :: lsouth(0:myDGSEM % nP)
   REAL(prec) :: lnorth(0:myDGSEM % nP)
   REAL(prec) :: least(0:myDGSEM % nS)
   REAL(prec) :: lwest(0:myDGSEM % nS)
   REAL(prec) :: ltop(0:myDGSEM % nQ)
   REAL(prec) :: lbottom(0:myDGSEM % nQ)
   REAL(prec) :: fL(1:nPrognostic), fR(1:nPrognostic)
   REAL(prec) :: fCori
   INTEGER    :: iS, iP, iQ, nS, nP, nQ, iEq

     CALL myDGSEM % dgStorage % GetNumberOfNodes( nS, nP, nQ )
     CALL myDGSEM % dgStorage % GetDerivativeMatrix( dMatX, dMatY, dMatZ )
     CALL myDGSEM % dgStorage % GetQuadratureWeights( qWeightX, qWeightY, qWeightZ )
     CALL myDGSEM % dgStorage % GetSouthernInterpolants( lsouth )
     CALL myDGSEM % dgStorage % GetNorthernInterpolants( lnorth )
     CALL myDGSEM % dgStorage % GetEasternInterpolants( least )
     CALL myDGSEM % dgStorage % GetWesternInterpolants( lwest )
     CALL myDGSEM % dgStorage % GetTopInterpolants( ltop )
     CALL myDGSEM % dgStorage % GetBottomInterpolants( lbottom )

      DO iQ = 0, nQ
         DO iP = 0,nP ! Loop over the y-points
            DO iS = 0,nS ! Loop over the x-points

               ! Get the metric terms to calculate the contravariant flux
               CALL myDGSEM % mesh % GetCovariantMetricsAtNode( iEl, &
                                                                dxds, dxdp, dxdq, &
                                                                dyds, dydp, dydq, &
                                                                dzds, dzdp, dzdq, &
                                                                iS, iP, iQ )

               ! Get the solution at x,y
               CALL myDGSEM % GetSolutionAtNode( iEl, iS, iP, iQ, sol )
               CALL myDGSEM % GetBackgroundStateAtNode( iEl, iS, iP, iQ, bsol )
               ! Calculate the x and y fluxes
               xF = XFlux(  sol, bsol )
               yF = YFlux(  sol, bsol )
               zF = ZFlux(  sol, bSol )

               !And now the contravariant flux
               contFlux(iS,:) = (dydp*dzdq - dzdp*dydq)*xF + &
                                (dxdq*dzdp - dxdp*dzdq)*yF + &
                                (dxdp*dydq - dxdq*dydp)*zF

            ENDDO ! iS, Loop over the x-points

            ! Get the numerical fluxes at the boundaries (should be calculated before
            ! this routine is called )
        
            ! Get the "west" flux at iP
            CALL myDGSEM % GetFluxAtBoundaryNode( iEl, west, iP, iQ, fL )

            ! Get the "east" flux at iP
            CALL myDGSEM % GetFluxAtBoundaryNode( iEl, east, iP, iQ, fR )

            ! At this y-level, calculate the DG-advective derivative
            DO iEq = 1, nPrognostic
               contFluxDer(0:nS,iEq) = DGSystemDerivative( nS, dMatX, qWeightX, fL(iEq), fR(iEq), &
                                                           contFlux(0:nS,iEq), lwest, least  )
            ENDDO
     
            DO iS = 0, nS ! Loop over the x-points
               DO iEq = 1, nPrognostic  ! Loop over the number of equations
                  tend(iS, iP, iQ, iEq) = -contFluxDer(iS,iEq)
               ENDDO ! Loop over the number of equations
            ENDDO ! Loop over the x-points

         ENDDO ! iP  


         DO iS = 0,nS ! Loop over the x-points
            DO iP = 0,nP ! Loop over the y-points

               ! Get the metric terms to calculate the contravariant flux
               CALL myDGSEM % mesh % GetCovariantMetricsAtNode( iEl, &
                                                                dxds, dxdp, dxdq, &
                                                                dyds, dydp, dydq, &
                                                                dzds, dzdp, dzdq, &
                                                                iS, iP, iQ )

               ! Get the solution at x,y
               CALL myDGSEM % GetSolutionAtNode( iEl, iS, iP, iQ, sol )
               CALL myDGSEM % GetBackgroundStateAtNode( iEl, iS, iP, iQ, bsol )
               ! Calculate the x and y fluxes
               xF = XFlux(  sol, bsol )
               yF = YFlux(  sol, bsol )
               zF = ZFlux(  sol, bsol )

               !And now the contravariant flux
               contFlux(iP,:) = (dydq*dzds - dzdq*dyds)*xF + &
                                 (dxds*dzdq - dxdq*dzds)*yF + &
                                 (dxdq*dyds - dxds*dydq)*zF

            ENDDO ! iP, Loop over the y-points

            ! Get the numerical fluxes at the boundaries (should be calculated before
            ! this routine is called )
        
            ! Get the "south" flux at iS
            CALL  myDGSEM % GetFluxAtBoundaryNode( iEl, south, iS, iQ, fL )

            ! Get the "north" flux at iS
            CALL  myDGSEM % GetFluxAtBoundaryNode( iEl, north, iS, iQ, fR )


            ! At this x-level, calculate the y-DG-advective derivative
            DO iEq = 1, nPrognostic
               contFluxDer(0:nP,iEq) = DGSystemDerivative(  nP, dMatY, qWeightY, fL(iEq), fR(iEq), &
                                                            contFlux(0:nP,iEq), lsouth, lnorth  )
            ENDDO

         
            DO iP = 0, nP 
               DO iEq = 1, nPrognostic 
                  tend(iS, iP, iQ, iEq) = tend(iS, iP, iQ, iEq)- contFluxDer(iP,iEq)
               ENDDO 
            ENDDO 

         ENDDO ! iS
      ENDDO ! iQ

      DO iP = 0 ,nP
         DO iS = 0, nS
            DO iQ = 0, nQ
               ! Get the metric terms to calculate the contravariant flux
               CALL myDGSEM % mesh % GetCovariantMetricsAtNode( iEl, &
                                                                dxds, dxdp, dxdq, &
                                                                dyds, dydp, dydq, &
                                                                dzds, dzdp, dzdq, &
                                                                iS, iP, iQ )

               ! Get the solution at x,y
               CALL myDGSEM % GetSolutionAtNode( iEl, iS, iP, iQ, sol )
               CALL myDGSEM % GetBackgroundStateAtNode( iEl, iS, iP, iQ, bsol )
               ! Calculate the x and y fluxes
               xF = XFlux(  sol, bsol )
               yF = YFlux(  sol, bsol )
               zF = ZFlux(  sol, bsol )

               !And now the contravariant flux
               contFlux(iQ,:) = (dyds*dzdp - dzds*dydp)*xF + &
                                 (dxdp*dzds - dxds*dzdp)*yF + &
                                 (dxds*dydp - dxdp*dyds)*zF

            ENDDO

            ! Get the numerical fluxes at the boundaries (should be calculated before
            ! this routine is called )
        
            ! Get the bottom flux
            CALL  myDGSEM % GetFluxAtBoundaryNode( iEl, bottom, iS, iP, fL )

            ! Get the top flux
            CALL  myDGSEM % GetFluxAtBoundaryNode( iEl, top, iS, iP, fR )


            ! At this x-level, calculate the y-DG-advective derivative
            DO iEq = 1, nPrognostic
               contFluxDer(0:nQ,iEq) = DGSystemDerivative(  nQ, dMatZ, qWeightY, fL(iEq), fR(iEq), &
                                                            contFlux(0:nP,iEq), lbottom, ltop  )
            ENDDO

         
            DO iQ = 0, nQ 
               CALL myDGSEM % mesh % GetJacobianAtNode( iEl, J, iS, iP, iQ )
               DO iEq = 1, nPrognostic  
                  tend(iS, iP, iQ, iEq) = ( tend(iS, iP, iQ, iEq)- contFluxDer(iQ,iEq) )/J
               ENDDO 
            ENDDO 

         ENDDO
      ENDDO
         
      ! COMPUTE THE SOURCE TERMS
      DO iQ = 0, nQ  
         DO iP = 0, nP
            DO iS = 0, nS

               CALL myDGSEM % GetSolutionAtNode( iEl, iS, iP, iQ, sol )
               CALL myDGSEM % mesh % GetPositionAtNode( iEl, x, y, z, iS, iP, iQ )
               CALL myDGSEM % GetPlanetaryVorticityAtNode( iEl, iS, iP, iQ, fCori )
                  
               tend(iS,iP,iQ,:) = tend(iS,iP,iQ,:) + Source( tn, sol, fCori, x, y, z )
            ENDDO
         ENDDO 
      ENDDO 

     CALL myDGSEM % SetTendency( iEl, tend )

 END SUBROUTINE MappedTimeDerivative_HydrostaticPrimitive
!
!
!  
SUBROUTINE BaroclinicEdgeFlux_HydrostaticPrimitive( myDGSEM, iFace, tn )
 ! S/R BaroclinicEdgeFlux
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iFace  
   REAL(prec), INTENT(in)                       :: tn
   ! Local
   INTEGER :: e1, s1, e2, s2, nS, nP, nQ
   INTEGER :: iStart, jStart, iInc, jInc, swapDim
   INTEGER :: i, j, k, l
   REAL(prec) :: flux(1:nPrognostic)
   REAL(prec) :: inState(0:myDGSEM % nS,0:myDGSEM % nP, 1:nHPEq)
   REAL(prec) :: exState(0:myDGSEM % nS,0:myDGSEM % nP, 1:nHPEq)
   REAL(prec) :: bgState(0:myDGSEM % nS,0:myDGSEM % nP, 1:nHPEq)
   REAL(prec) :: inS(1:nHPEq), outS(1:nHPEq), bgS(1:nHPEq)
   REAL(prec) :: x, y, z
   REAL(prec) :: nHat(1:nDim), nHatLength
    

      CALL myDGSEM % dgStorage % GetNumberOfNodes( nS, nP, nQ )
      
      CALL myDGSEM % mesh % GetFacePrimaryElementID( iFace, e1 )
      CALL myDGSEM % mesh % GetFacePrimaryElementSide( iFace, s1 )
      CALL myDGSEM % mesh % GetFaceSecondaryElementID( iFace, e2 )
      CALL myDGSEM % mesh % GetFaceSecondaryElementSide( iFace, s2 )
      
      s2 = ABS(s2)

      CALL myDGSEM % mesh % GetFaceStart( iFace, iStart, jStart )
      CALL myDGSEM % mesh % GetFaceIncrement( iFace, iInc, jInc )
      CALL myDGSEM % mesh % GetSwapDimensions( iFace, swapDim )

      CALL myDGSEM % baroclinic(e1) % GetSolutionAtBoundary( s1, inState )
      !CALL myDGSEM % GetBackgroundStateAtBoundary( e1, s1, bgState )
      bgState = ZERO
      IF( e2 > 0 )then ! this is an interior edge
      
         
         CALL myDGSEM % baroclinic(e2) % GetSolutionAtBoundary( s2, exState )
        
         k = (iStart-iInc)*(1-swapDim) + (jStart-jInc)*(swapDim)
         l = (iStart-iInc)*(swapDim) + (jStart-jInc)*(1-swapDim)
         
         DO j = 0, nS ! Loop over the nodes
         
            k = (k + (jInc)*(swapDim))*(swapDim) + (iStart-iInc)*(1-swapDim)
            l = (l + (jInc)*(1-swapDim))*(1-swapDim) + (iStart-iInc)*(swapDim)
            
            DO i = 0, nP
               k = k + (iInc)*(1-swapDim)
               l = l + (iInc)*(swapDim)
              
               CALL myDGSEM % mesh % GetBoundaryNormalAtNode( e1, nHat, nHatLength, i, j, s1 ) ! Get nHat

               inS  = inState(i,j,1:nHPEq)
               outS = exState(k,l,1:nHPEq)
               bgS  = bgState(i,j,1:nHPEq)
               flux = RiemannSolver( inS, outS, bgS, nHat )*nHatLength

               ! Store the flux for the elements which share this edge
               CALL myDGSEM % SetFluxAtBoundaryNode( e1, s1, i, j, flux )
               CALL myDGSEM % SetFluxAtBoundaryNode( e2, s2, k, l, -flux )


            ENDDO ! i, 
         ENDDO ! j, loop over the nodes
         
      ELSE ! this edge is a boundary edge

         DO j = 0, nS ! loop over the nodes
            DO i = 0, nP
               
               CALL myDGSEM % mesh % GetBoundaryNormalAtNode( e1, nHat, nHatLength, i, j, s1 ) ! Get nHat
            
               ! Get the boundary point locations
               CALL myDGSEM % mesh % GetBoundaryLocationAtNode( e1, x, y, z, i, j, s1 )

               ! Calculate the external state
               inS = inState(i,j,1:nHPEq)
               outS = GetExternalState( x, y, z, tn, nHat, e2, inS )
             !  outS = exState(i,j,1:nHPEq)
               bgS  = bgState(i,j,1:nHPEq)
               flux =  RiemannSolver( inS, outS, bgS, nHat )*nHatLength
 
               CALL myDGSEM % SetFluxAtBoundaryNode( e1, s1, i, j, flux )

            ENDDO 
         ENDDO ! j, loop over the nodes on this edge

      ENDIF ! Choosing the edge type
 
 END SUBROUTINE BaroclinicEdgeFlux_HydrostaticPrimitive
!
!
!
 SUBROUTINE BaroclinicTendency_HydrostaticPrimitive( myDGSEM, iEl, tn ) 
 ! S/R BaroclinicTendency
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(HydrostaticPrimitive), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)             :: iEl
   REAL(prec), INTENT(in)          :: tn
   ! LOCAL
   REAL(prec) :: dxds, dxdp, dxdq, dyds, dydp, dydq, dzds, dzdp, dzdq
   REAL(prec) :: J, x, y, z
   REAL(prec) :: xF(1:nPrognostic), yF(1:nPrognostic), zF(1:nPrognostic)
   REAL(prec) :: sol(1:nHPEq), bsol(1:nHPEq)
   REAL(prec) :: contFlux(0:myDGSEM % nS,1:nPrognostic)
   REAL(prec) :: contFluxDer(0:myDGSEM % nS,1:nPrognostic)
   REAL(prec) :: tend(0:myDGSEM % nS,0:myDGSEM % nP,0:myDGSEM % nQ,1:nPrognostic)
   REAL(prec) :: dMatX(0:myDGSEM % nS,0:myDGSEM % nS)
   REAL(prec) :: dMatY(0:myDGSEM % nP,0:myDGSEM % nP)
   REAL(prec) :: dMatZ(0:myDGSEM % nQ,0:myDGSEM % nQ)
   REAL(prec) :: qWeightX(0:myDGSEM % nS)
   REAL(prec) :: qWeightY(0:myDGSEM % nP)
   REAL(prec) :: qWeightZ(0:myDGSEM % nQ)
   REAL(prec) :: lsouth(0:myDGSEM % nP)
   REAL(prec) :: lnorth(0:myDGSEM % nP)
   REAL(prec) :: least(0:myDGSEM % nS)
   REAL(prec) :: lwest(0:myDGSEM % nS)
   REAL(prec) :: ltop(0:myDGSEM % nQ)
   REAL(prec) :: lbottom(0:myDGSEM % nQ)
   REAL(prec) :: fL(1:nPrognostic), fR(1:nPrognostic)
   REAL(prec) :: fCori
   INTEGER    :: iS, iP, iQ, nS, nP, nQ, iEq

      CALL myDGSEM % dgStorage % GetNumberOfNodes( nS, nP, nQ )
      CALL myDGSEM % dgStorage % GetDerivativeMatrix( dMatX, dMatY, dMatZ )
      CALL myDGSEM % dgStorage % GetQuadratureWeights( qWeightX, qWeightY, qWeightZ )
      CALL myDGSEM % dgStorage % GetSouthernInterpolants( lsouth )
      CALL myDGSEM % dgStorage % GetNorthernInterpolants( lnorth )
      CALL myDGSEM % dgStorage % GetEasternInterpolants( least )
      CALL myDGSEM % dgStorage % GetWesternInterpolants( lwest )
      CALL myDGSEM % dgStorage % GetTopInterpolants( ltop )
      CALL myDGSEM % dgStorage % GetBottomInterpolants( lbottom )
      bSol = ZERO
      DO iQ = 0, nQ
         DO iP = 0,nP ! Loop over the y-points
            DO iS = 0,nS ! Loop over the x-points

               ! Get the metric terms to calculate the contravariant flux
               CALL myDGSEM % mesh % GetCovariantMetricsAtNode( iEl, &
                                                                dxds, dxdp, dxdq, &
                                                                dyds, dydp, dydq, &
                                                                dzds, dzdp, dzdq, &
                                                                iS, iP, iQ )

               ! Get the solution at x,y
               CALL myDGSEM % baroclinic(iEl) % GetSolutionAtNode( iS, iP, iQ, sol )
               !CALL myDGSEM % GetBackgroundStateAtNode( iEl, iS, iP, iQ, bsol )
               ! Calculate the x and y fluxes
               xF = XFlux(  sol, bsol )
               yF = YFlux(  sol, bsol )
               zF = ZFlux(  sol, bSol )

               !And now the contravariant flux
               contFlux(iS,:) = (dydp*dzdq - dzdp*dydq)*xF + &
                                (dxdq*dzdp - dxdp*dzdq)*yF + &
                                (dxdp*dydq - dxdq*dydp)*zF

            ENDDO ! iS, Loop over the x-points

            ! Get the numerical fluxes at the boundaries (should be calculated before
            ! this routine is called )
        
            ! Get the "west" flux at iP
            CALL myDGSEM % baroclinic(iEl) % GetFluxAtBoundaryNode( west, iP, iQ, fL )

            ! Get the "east" flux at iP
            CALL myDGSEM % baroclinic(iEl) % GetFluxAtBoundaryNode( east, iP, iQ, fR )

            ! At this y-level, calculate the DG-advective derivative
            DO iEq = 1, nPrognostic
               contFluxDer(0:nS,iEq) = DGSystemDerivative( nS, dMatX, qWeightX, fL(iEq), fR(iEq), &
                                                           contFlux(0:nS,iEq), lwest, least  )
            ENDDO
     
            DO iS = 0, nS ! Loop over the x-points
               DO iEq = 1, nPrognostic  ! Loop over the number of equations
                  tend(iS, iP, iQ, iEq) = -contFluxDer(iS,iEq)
               ENDDO ! Loop over the number of equations
            ENDDO ! Loop over the x-points

         ENDDO ! iP  


         DO iS = 0,nS ! Loop over the x-points
            DO iP = 0,nP ! Loop over the y-points

               ! Get the metric terms to calculate the contravariant flux
               CALL myDGSEM % mesh % GetCovariantMetricsAtNode( iEl, &
                                                                dxds, dxdp, dxdq, &
                                                                dyds, dydp, dydq, &
                                                                dzds, dzdp, dzdq, &
                                                                iS, iP, iQ )

               ! Get the solution at x,y
               CALL myDGSEM % baroclinic(iEl) % GetSolutionAtNode( iS, iP, iQ, sol )
             !  CALL myDGSEM % GetBackgroundStateAtNode( iEl, iS, iP, iQ, bsol )
               ! Calculate the x and y fluxes
               xF = XFlux(  sol, bsol )
               yF = YFlux(  sol, bsol )
               zF = ZFlux(  sol, bsol )

               !And now the contravariant flux
               contFlux(iP,:) = (dydq*dzds - dzdq*dyds)*xF + &
                                 (dxds*dzdq - dxdq*dzds)*yF + &
                                 (dxdq*dyds - dxds*dydq)*zF

            ENDDO ! iP, Loop over the y-points

            ! Get the numerical fluxes at the boundaries (should be calculated before
            ! this routine is called )
        
            ! Get the "south" flux at iS
            CALL  myDGSEM % baroclinic(iEl) % GetFluxAtBoundaryNode( south, iS, iQ, fL )

            ! Get the "north" flux at iS
            CALL  myDGSEM % baroclinic(iEl) % GetFluxAtBoundaryNode( north, iS, iQ, fR )


            ! At this x-level, calculate the y-DG-advective derivative
            DO iEq = 1, nPrognostic
               contFluxDer(0:nP,iEq) = DGSystemDerivative(  nP, dMatY, qWeightY, fL(iEq), fR(iEq), &
                                                            contFlux(0:nP,iEq), lsouth, lnorth  )
            ENDDO

         
            DO iP = 0, nP 
               DO iEq = 1, nPrognostic 
                  tend(iS, iP, iQ, iEq) = tend(iS, iP, iQ, iEq)- contFluxDer(iP,iEq)
               ENDDO 
            ENDDO 

         ENDDO ! iS
      ENDDO ! iQ

      DO iP = 0 ,nP
         DO iS = 0, nS
            DO iQ = 0, nQ
               ! Get the metric terms to calculate the contravariant flux
               CALL myDGSEM % mesh % GetCovariantMetricsAtNode( iEl, &
                                                                dxds, dxdp, dxdq, &
                                                                dyds, dydp, dydq, &
                                                                dzds, dzdp, dzdq, &
                                                                iS, iP, iQ )

               ! Get the solution at x,y
               CALL myDGSEM % baroclinic(iEl) % GetSolutionAtNode( iS, iP, iQ, sol )
               !CALL myDGSEM % GetBackgroundStateAtNode( iEl, iS, iP, iQ, bsol )
               ! Calculate the x and y fluxes
               xF = XFlux(  sol, bsol )
               yF = YFlux(  sol, bsol )
               zF = ZFlux(  sol, bsol )

               !And now the contravariant flux
               contFlux(iQ,:) = (dyds*dzdp - dzds*dydp)*xF + &
                                 (dxdp*dzds - dxds*dzdp)*yF + &
                                 (dxds*dydp - dxdp*dyds)*zF

            ENDDO

            ! Get the numerical fluxes at the boundaries (should be calculated before
            ! this routine is called )
        
            ! Get the bottom flux
            CALL  myDGSEM % baroclinic(iEl) % GetFluxAtBoundaryNode( bottom, iS, iP, fL )

            ! Get the top flux
            CALL  myDGSEM % baroclinic(iEl) % GetFluxAtBoundaryNode( top, iS, iP, fR )


            ! At this x-level, calculate the y-DG-advective derivative
            DO iEq = 1, nPrognostic
               contFluxDer(0:nQ,iEq) = DGSystemDerivative(  nQ, dMatZ, qWeightY, fL(iEq), fR(iEq), &
                                                            contFlux(0:nP,iEq), lbottom, ltop  )
            ENDDO

         
            DO iQ = 0, nQ 
               CALL myDGSEM % mesh % GetJacobianAtNode( iEl, J, iS, iP, iQ )
               DO iEq = 1, nPrognostic  
                  tend(iS, iP, iQ, iEq) = ( tend(iS, iP, iQ, iEq)- contFluxDer(iQ,iEq) )/J
               ENDDO 
            ENDDO 

         ENDDO
      ENDDO
         
      ! COMPUTE THE SOURCE TERMS

     CALL myDGSEM % baroclinic(iEl) % SetTendency( tend )

 END SUBROUTINE BaroclinicTendency_HydrostaticPrimitive
!
!
!  

 FUNCTION DGSystemDerivative(  nP, dMat, qWei, lFlux, rFlux, intFlux, lagLeft, lagRight  ) RESULT( tendency )
 ! FUNCTION DGSystemDerivative ( Discontinous Galerkin time Derivative)
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   INTEGER    :: nP
   REAL(prec) :: dMat(0:nP,0:nP)
   REAL(prec) :: qWei(0:nP)
   REAL(prec) :: lFlux
   REAL(prec) :: rFlux
   REAL(prec) :: intFlux(0:nP)
   REAL(prec) :: lagLeft(0:nP), lagRight(0:nP)
   REAL(prec) :: tendency(0:nP)
   ! Local 
   INTEGER :: kP

      ! Apply the derivative operator
      tendency = MATMUL( dMat, intflux )

      DO kP = 0, nP ! Loop over the quadrature points
            tendency(kP) = tendency(kP) + ( rFlux*lagRight(kP) + lFlux*lagLeft(kP) )/qWei(kP)
      ENDDO ! kP, loop over the quadrature points
                                         
 END FUNCTION DGSystemDerivative
!
!
!
 FUNCTION RiemannSolver( inState, outState, backgroundState, nHat ) RESULT( numFlux )
 ! FUNCTION RiemannSolver 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   REAL(prec) :: inState(1:nHPEq)
   REAL(prec) :: outState(1:nHPEq)
   REAL(prec) :: backgroundState(1:nHPEq)
   REAL(prec) :: nHat(1:nDim) ! normal direction
   REAL(prec) :: numFlux(1:nPrognostic)
   
   ! LOCAL
   REAL(prec) :: uN, uIN, uEx
   REAL(prec) :: fIn(1:nPrognostic), fEx(1:nPrognostic)
   REAL(prec) :: jump(1:nPrognostic)


      jump = outState(1:nPrognostic) - inState(1:nPrognostic)

      fIn = XFlux( inState, backgroundState )*nHat(1) + &
            YFlux( inState, backgroundState )*nHat(2) + &
            ZFlux( inState, backgroundState )*nHat(3) 

      fEx = XFlux( outState, backgroundState )*nHat(1) + &
            YFlux( outState, backgroundState )*nHat(2) + &
            ZFlux( outState, backgroundState )*nHat(3) 

      uIn = ( inState(wEq) + backgroundState(wEq) )*nHat(3)

      uEx = ( outState(wEq) + backgroundState(wEq) )*nHat(3)

      uN = max( abs(uIn), abs(uEx) )

    !  numFlux = HALF*( fEx + fIn - abs(uN)*jump )

      numFlux(1) = HALF*( instate(pEq) + outstate(pEq) )*nHat(1)
      numFlux(2) = HALF*( instate(pEq) + outState(pEq) )*nHat(2)
      numFlux(3) = HALF*( fEx(3) + fIn(3) - uN*jump(3) )

 END FUNCTION RiemannSolver
!
!
! 
 FUNCTION XFlux( solAtX, backgroundSol ) RESULT( fx )
 ! FUNCTION XFlux
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE 
   REAL(prec) :: solAtX(1:nHPEq)
   REAL(prec) :: backgroundSol(1:nHPEq)
   REAL(prec) :: fx(1:nPrognostic)

      fx(1) = solAtX(pEq) !( TWO*backgroundSol(1)*solAtX(1) + solAtX(pEq) )             ! 2Uu + P
      fx(2) = ZERO !( backgroundSol(1)*solAtX(2) + backgroundSol(2)*solAtX(1) )  ! Uv + Vu 
      fx(3) = ZERO !( backgroundSol(1)*solAtX(3) + backgroundSol(3)*solAtX(1) )  ! Ub + Bu

 END FUNCTION XFlux
!
!
!
 FUNCTION YFlux( solAtX, backgroundSol ) RESULT( fy )
 ! FUNCTION YFlux
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE 
   REAL(prec) :: solAtX(1:nHPEq)
   REAL(prec) :: backgroundSol(1:nHPEq)
   REAL(prec) :: fy(1:nPrognostic)

      fy(1) = ZERO !( backgroundSol(1)*solAtX(2) + backgroundSol(2)*solAtX(1) )  ! Uv + Vu             
      fy(2) = solAtX(pEq) ! ( TWO*backgroundSol(2)*solAtX(2) + solAtX(pEq) )             ! 2Vv + P
      fy(3) = ZERO !( backgroundSol(2)*solAtX(3) + backgroundSol(3)*solAtX(2) )  ! Vb + Bv

 END FUNCTION YFlux
!
!
!
FUNCTION ZFlux( solAtX, backgroundSol ) RESULT( fz )
 ! FUNCTION ZFlux
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE 
   REAL(prec) :: solAtX(1:nHPEq)
   REAL(prec) :: backgroundSol(1:nHPEq)
   REAL(prec) :: fz(1:nPrognostic)

      fz(1) = ZERO ! ( backgroundSol(1)*solAtX(wEq) + backgroundSol(wEq)*solAtX(1) )  ! Uw + Wu             
      fz(2) = ZERO !( backgroundSol(2)*solAtX(wEq) + backgroundSol(wEq)*solAtX(2) )  ! Vw + Wv
      fz(3) = backgroundSol(3)*solAtX(wEq)!( backgroundSol(3)*solAtX(wEq) + backgroundSol(wEq)*solAtX(3) )  ! Bw + Wb

 END FUNCTION ZFlux
!
!
!           
 FUNCTION Source( tn, sol, fCori, x, y, z ) RESULT( q )
 ! FUNCTION Source
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   REAL(prec)     :: tn
   REAL(prec)     :: sol(1:nHPEq), fCori
   REAL(prec)     :: x, y, z
   REAL(prec)     :: q(1:nPrognostic)

      q(1) = ZERO!fCori*sol(2)   !  fv
      q(2) = ZERO!-fCori*sol(1)  ! -fu
      q(3) = ZERO


 END FUNCTION Source
!
!
!
 FUNCTION GetExternalState( x, y, z, t, nHat, bcFlag, intState ) RESULT( extState )
 ! S/R GetExternalState
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   REAL(prec) :: intState(1:nHPEq)
   REAL(prec) :: x, y, z, t
   REAL(prec) :: nHat(1:nDim)
   INTEGER    :: bcFlag 
   REAL(prec) :: extState(1:nHPEq)

       extState = ZERO 

       IF( bcFlag == NO_NORMAL_FLOW )THEN
      
          extState(1)   = (nHat(2)*nHat(2) -nHat(1)*nHat(1))*intState(1) - TWO*nHat(1)*nHat(2)*intState(2) ! u velocity
          extState(2)   = (nHat(1)*nHat(1) -nHat(2)*nHat(2))*intState(2) - TWO*nHat(1)*nHat(2)*intState(1) ! v velocity
          extState(3)   = ZERO
          extState(4)   = ZERO
          extState(5)   = intState(5) 
  
       ELSEIF( bcFlag == SEA_FLOOR )THEN

          extState(1)   = intState(1)
          extState(2)   = intState(2)
          extState(3)   = ZERO
          extState(4) = -( intState(4) + TWO*(intState(1)*nHat(1) + intState(2)*nHat(2)) )/nHat(3)
          extState(5) = intState(5)

       ELSEIF( bcFlag == RADIATION ) THEN

          extState = ZERO

       ELSE   
       
         PRINT*, 'FUNCTION : GetExternalState : Invalid bcflag =', bcflag
         extState = ZERO
         
       ENDIF

        
 END FUNCTION GetExternalState
!
!
!==================================================================================================!
!-------------------------------------- FILE I/O ROUTINES -----------------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE CoarseToFine_HydrostaticPrimitive( myDGSEM, iEl, x, y, z, s )
 ! CoarseToFine
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(in) :: myDGSEM
   INTEGER, INTENT(in)            :: iEl
   REAL(prec), INTENT(out)        :: x(0:myDGSEM % nPlot, 0:myDGSEM % nPlot, 0:myDGSEM % nPlot)
   REAL(prec), INTENT(out)        :: y(0:myDGSEM % nPlot, 0:myDGSEM % nPlot, 0:myDGSEM % nPlot)
   REAL(prec), INTENT(out)        :: z(0:myDGSEM % nPlot, 0:myDGSEM % nPlot, 0:myDGSEM % nPlot)
   REAL(prec), INTENT(out)        :: s(0:myDGSEM % nPlot, 0:myDGSEM % nPlot, 0:myDGSEM % nPlot,1:nHPEq)
   ! Local
   REAL(prec) :: localX(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec) :: localY(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec) :: localZ(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   REAL(prec) :: sol(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ, 1:nHPEq)
   INTEGER    :: iEq


      CALL myDGSEM % GetSolution( iEl, sol )
      CALL myDGSEM % mesh % GetPositions( iEl, localX, localY, localZ )
      
      CALL myDGSEM % dgStorage % interp % CoarseToFine( localX, &
                                                        myDGSEM % plMatS, &
                                                        myDGSEM % plMatP, &
                                                        myDGSEM % plMatQ, &
                                                        myDGSEM % nPlot, &
                                                        myDGSEM % nPlot, &
                                                        myDGSEM % nPlot, &
                                                        x )
      
      CALL myDGSEM % dgStorage % interp % CoarseToFine( localY, &
                                                        myDGSEM % plMatS, &
                                                        myDGSEM % plMatP, &
                                                        myDGSEM % plMatQ, &
                                                        myDGSEM % nPlot, &
                                                        myDGSEM % nPlot, &
                                                        myDGSEM % nPlot, &
                                                        y )
                                                    
      CALL myDGSEM % dgStorage % interp % CoarseToFine( localZ, &
                                                        myDGSEM % plMatS, &
                                                        myDGSEM % plMatP, &
                                                        myDGSEM % plMatQ, &
                                                        myDGSEM % nPlot, &
                                                        myDGSEM % nPlot, &
                                                        myDGSEM % nPlot, &
                                                        z )



      DO iEq = 1, nHPEq                                        
         CALL myDGSEM % dgStorage % interp % CoarseToFine( sol(:,:,:,iEq), &
                                                           myDGSEM % plMatS, &
                                                           myDGSEM % plMatP, &
                                                           myDGSEM % plMatQ, &
                                                           myDGSEM % nPlot, &
                                                           myDGSEM % nPlot, &
                                                           myDGSEM % nPlot, &
                                                           s(:,:,:,iEq) )  
      ENDDO                               
      
 END SUBROUTINE CoarseToFine_HydrostaticPrimitive
!
!
!
 SUBROUTINE WriteTecplot_HydrostaticPrimitive( myDGSEM, iter )
 ! S/R WriteTecplot
 !  
 ! =============================================================================================== !
 ! DECLARATIONS
  IMPLICIT NONE
  CLASS( HydrostaticPrimitive ), INTENT(inout)  :: myDGsem
  INTEGER, INTENT(in), OPTIONAL :: iter
  !LOCAL
  REAL(prec)  :: x(0:myDGSEM % nPlot,0:myDGSEM % nPlot,0:myDGSEM % nPlot)
  REAL(prec)  :: y(0:myDGSEM % nPlot,0:myDGSEM % nPlot,0:myDGSEM % nPlot)
  REAL(prec)  :: z(0:myDGSEM % nPlot,0:myDGSEM % nPlot,0:myDGSEM % nPlot)
  REAL(prec)  :: s(0:myDGSEM % nPlot,0:myDGSEM % nPlot,0:myDGSEM % nPlot,1:myDGSEM % nEq)
  INTEGER     :: iS, iP, iQ, iEl, fUnit, nPlot
  CHARACTER(len=5) :: zoneID
  CHARACTER(len=10) :: iterChar
  CHARACTER(len=50) :: freesurffile

    nPlot = myDGSEM % nPlot
    
    IF( PRESENT(iter) )THEN
       WRITE(iterChar,'(I10.10)')iter
       OPEN( UNIT=NEWUNIT(fUnit), &
             FILE= 'HPEState.'//iterChar//'.tec', &
             FORM='formatted', &
             STATUS='replace')
       freesurffile='freesurf.'//iterChar
    ELSE
       OPEN( UNIT=NEWUNIT(fUnit), &
             FILE= 'HPEState.init.tec', &
             FORM='formatted', &
             STATUS='replace')  
       freesurffile='freesurf.init'
    ENDIF
    
    WRITE(fUnit,*) 'VARIABLES = "X", "Y","Z", "U", "V", "W", "B", "P" '
 
    DO iEl = 1, myDGsem % mesh % nElems

        CALL myDGSEM % CoarseToFine( iEl, x, y, z, s )
        WRITE(zoneID,'(I5.5)') iEl
        WRITE(fUnit,*) 'ZONE T="el'//trim(zoneID)//'", I=',nPlot+1,', J=', nPlot+1,', K=', nPlot+1,',F=POINT'

        DO iQ = 0, nPlot
           DO iP = 0, nPlot
              DO iS = 0, nPlot
                 WRITE (fUnit,*)  x(iS,iP,iQ), y(iS,iP,iQ), z(iS,iP,iQ), &
                                  s(iS,iP,iQ,1), s(iS,iP,iQ,2), s(iS,iP,iQ,wEq), &
                                  s(iS,iP,iQ,3), s(iS,iP,iQ,pEq)
              ENDDO
           ENDDO
        ENDDO
        
    ENDDO

    CLOSE(UNIT=fUnit)

    CALL myDGSEM % freeSurface % WriteTecplot(freesurffile)

 END SUBROUTINE WriteTecplot_HydrostaticPrimitive
!
!
!
 SUBROUTINE WritePickup_HydrostaticPrimitive( myDGSEM, iter )
 ! S/R WritePickup
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iter
  ! LOCAL
   REAL(prec)    :: sol(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ, 1:nHPEq)
   REAL(prec)    :: f(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   CHARACTER(10) :: iterChar
   INTEGER       :: iEl
   INTEGER       :: thisRec, fUnit
   INTEGER       :: iEq, nS, nP, nQ

     nS = myDGSEM % nS
     nP = myDGSEM % nP
     nQ = myDGSEM % nQ
     
     WRITE(iterChar,'(I10.10)') iter

     OPEN( UNIT=NEWUNIT(fUnit), &
           FILE='HydrostaticPrimitive.'//iterChar//'.pickup', &
           FORM='unformatted',&
           ACCESS='direct',&
           STATUS='replace',&
           ACTION='WRITE',&
           CONVERT='big_endian',&
           RECL=prec*(nS+1)*(nP+1)*(nQ+1) )

      thisRec = 1 
      DO iEl = 1, myDGSEM % mesh % nElems
        
         CALL myDGSEM % GetSolution( iEl, sol )
         DO iEq = 1, myDGSEM % nEq
            WRITE( fUnit, REC=thisRec )sol(:,:,:,iEq) 
            thisRec = thisRec+1
         ENDDO

         CALL myDGSEM % GetBackgroundState( iEl, sol )
         DO iEq = 1, myDGSEM % nEq
            WRITE( fUnit, REC=thisRec )sol(:,:,:,iEq) 
            thisRec = thisRec+1
         ENDDO

         CALL myDGSEM % GetPlanetaryVorticity( iEl, f )
         
         WRITE( fUnit, REC=thisRec )f 
         thisRec = thisRec+1

     ENDDO

     CLOSE(UNIT=fUnit)

     CALL myDGSEM % freesurface % WritePickup( iter )

 END SUBROUTINE WritePickup_HydrostaticPrimitive
!
!
!
  SUBROUTINE ReadPickup_HydrostaticPrimitive( myDGSEM, iter )
 ! S/R ReadPickup
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   INTEGER, INTENT(in)                          :: iter
  ! LOCAL
   REAL(prec)    :: sol(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ, 1:myDGSEM % nEq)
   REAL(prec)    :: f(0:myDGSEM % nS, 0:myDGSEM % nP, 0:myDGSEM % nQ)
   CHARACTER(10) :: iterChar
   INTEGER       :: iEl
   INTEGER       :: thisRec, fUnit
   INTEGER       :: iEq, nS, nP, nQ

     nS = myDGSEM % nS
     nP = myDGSEM % nP
     nQ = myDGSEM % nQ
     
     WRITE(iterChar,'(I10.10)') iter

     OPEN( UNIT=NEWUNIT(fUnit), &
           FILE='HydrostaticPrimitive.'//iterChar//'.pickup', &
           FORM='unformatted',&
           ACCESS='direct',&
           STATUS='old',&
           ACTION='READ',&
           CONVERT='big_endian',&
           RECL=prec*(nS+1)*(nP+1)*(nQ+1) )
     
     thisRec = 1
     DO iEl = 1, myDGSEM % mesh % nElems
        
        DO iEq = 1, myDGSEM % nEq
           READ( fUnit, REC=thisRec )sol(:,:,:,iEq) 
           thisRec = thisRec+1
        ENDDO
        CALL myDGSEM % SetSolution( iEl, sol )
        
        DO iEq = 1, myDGSEM % nEq
           READ( fUnit, REC=thisRec )sol(:,:,:,iEq) 
           thisRec = thisRec+1
        ENDDO
        CALL myDGSEM % SetBackgroundState( iEl, sol )

        READ( fUnit, REC=thisRec )f
        CALL myDGSEM % SetPlanetaryVorticity( iEl, f )
        thisRec = thisRec + 1
     ENDDO

     CLOSE(UNIT=fUnit)

     CALL myDGSEM % freesurface % ReadPickup( iter )

 END SUBROUTINE ReadPickup_HydrostaticPrimitive
!
!
! 
 END MODULE HydrostaticPrimitivesClass



