! ShallowWater_InitialConditions.f90
! 
! Copyright 2015 Joseph Schoonover <schoonover.numerics@gmail.com>
! 
! ShallowWater_InitialConditions.f90 is part of the Spectral Element Libraries in Fortran (SELF).
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
 
 
PROGRAM ShallowWater_InitialConditions
! ========================================= Logs ================================================= !
!2016-05-11  Joseph Schoonover  schoonover.numerics@gmail.com 
!
! //////////////////////////////////////////////////////////////////////////////////////////////// ! 


! src/common/
USE ModelPrecision
! src/geom/
USE QuadMeshClass
! src/highend/shallowwater
USE SWParamsClass
USE ShallowWaterClass

 IMPLICIT NONE

 TYPE( ShallowWater ) :: mysw

 INTEGER :: iEl
 
    CALL mysw % Build( )
 

    CALL Bathymetry( mysw )   
    CALL InitialCondition( mysw )

    
    CALL mysw % WritePickup( 0 ) 
    CALL mysw % WriteTecplot( 'ShallowWater.init' )
    CALL mysw % mesh % WriteTecplot( )
    
    CALL mysw % Trash( )

 CONTAINS
 
 SUBROUTINE Bathymetry( myDGSEM )
 ! S/R Bathymetry
 !
 !    This subroutine sets the bathymetry as a flat bottom with a unit depth
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   TYPE( ShallowWater ), INTENT(inout) :: myDGSEM
   ! Local
   INTEGER    :: iS, iP, iEl, nS, nP, nEl
   REAL(prec) :: x, y
   REAL(prec) :: h(0:myDGSEM % nS,0:myDGSEM % nP,1:3)
   
      CALL myDGSEM % dgStorage % GetNumberOfNodes( nS, nP )
      nEl = myDGSEM % mesh % nElems
      
      h = ZERO
      
      DO iEl = 1, nEl
         DO iP = 0, nP
            DO iS = 0, nS
   
               h(iS,iP,1) = ONE
               
            ENDDO
         ENDDO
         
         CALL myDGSEM % SetBathymetry( iEl, h )
      ENDDO
      
 END SUBROUTINE Bathymetry
!
!
!
 SUBROUTINE InitialCondition( myDGSEM )
 ! S/R InitialCondition
 !
 !    This subroutine (in v2.1) constructs a geostrophic dipole by setting the free surface height
 !    and calculating the velocity from geostrophy.
 !
 ! ==============================================================================================  !
 ! DECLARATIONS
   TYPE( ShallowWater ), INTENT(inout) :: myDGSEM
   ! Local
   INTEGER    :: iS, iP, iEl, nS, nP, nEl
   REAL(prec) :: f0, x, y
   REAL(prec) :: f(0:myDGSEM % nS,0:myDGSEM % nP)
   REAL(prec) :: sol(0:myDGSEM % nS,0:myDGSEM % nP,1:3)
   REAL(prec) :: dpdx, dpdy
   REAL(prec) :: eta0, x0, y0, x1, y1, L
   
      eta0 = 0.05_prec
      x0   = 0.5_prec
      y0   = 0.7_prec
      x1   = 0.5_prec
      y1   = 0.3_prec
      L    = 0.1_prec
   
      CALL myDGSEM % dgStorage % GetNumberOfNodes( nS, nP )
      nEl = myDGSEM % mesh % nElems
      f0 = myDGSEM % params % f0
      
      sol = ZERO
      
      DO iEl = 1, nEl
         DO iP = 0, nP
            DO iS = 0, nS
            
               CALL myDGSEM % mesh % GetPositionAtNode( iEl, x, y, iS, iP )
               f(iS,iP) = f0         
               
               ! Setting the dipole free surface height
               sol(iS,iP,3) = eta0*( exp( -( (x-x0)**2 + (y-y0)**2 )/(2.0_prec*L**2)  ) - &
                                     exp( -( (x-x1)**2 + (y-y1)**2 )/(2.0_prec*L**2)  )  )      
               
            ENDDO
         ENDDO
         
         CALL myDGSEM % SetSolution( iEl, sol )
         CALL myDGSEM % SetPlanetaryVorticity( iEl, f )
      ENDDO
      
      ! Calculating the tendency gives the pressure gradient
      CALL myDGSEM % GlobalTimeDerivative( ZERO )
      
      ! Use the tendency to calculate the velocity by invoking geostrophic balance  
      DO iEl = 1, nEl
         DO iP = 0, nP
            DO iS = 0, nS
               ! Get the (negative) pressure gradient
               CALL myDGSEM % GetTendencyAtNodeWithVarID( iEl, iS, iP, 1, dpdx )
               CALL myDGSEM % GetTendencyAtNodeWithVarID( iEl, iS, iP, 2, dpdy )
               ! Flip the sign on the negative pressure gradient
               dpdx = -dpdx
               dpdy = -dpdy
               
               ! Set the "zonal" velocity
               sol(iS,iP,1) = -dpdy/f0
               ! Set the "meridional" velocity
               sol(iS,iP,2) = dpdx/f0
            ENDDO
         ENDDO
         CALL myDGSEM % SetVelocity( iEl, sol(:,:,1), sol(:,:,2) )
      ENDDO
               
               
 END SUBROUTINE InitialCondition
!
!
! 
 
END PROGRAM ShallowWater_InitialConditions
