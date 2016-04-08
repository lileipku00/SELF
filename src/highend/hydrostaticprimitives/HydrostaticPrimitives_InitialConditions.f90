PROGRAM HydrostaticPrimitives_InitialConditions



! src/common/
USE ModelPrecision
! src/geom/
USE StackedHexMeshClass
! src/highend/advection2d
USE HydrostaticParams_Class
USE HydrostaticPrimitivesClass

 IMPLICIT NONE

 TYPE( HydrostaticPrimitive ) :: myHyd
 
    CALL myHyd % Build( InitializeOnly = .TRUE. )
   
    CALL InitialCondition( myHyd )

    CALL myHyd % GlobalTimeDerivative( ZERO, 0 )
 
    CALL myHyd % WritePickup( 0 ) 
    CALL myHyd % WriteTecplot(  )
    
    CALL myHyd % mesh % WriteTecplot( )

    CALL myHyd % mesh % WriteMeshFile( GAUSS, LEGENDRE_BASIS )

    CALL myHyd % freesurface % WriteMask( )
    CALL myHyd % freesurface % preconditioner % WriteMaskPC( )

    CALL myHyd % Trash( )

 CONTAINS
 

 SUBROUTINE InitialCondition( myDGSEM )
 ! S/R InitialCondition
 !
 !    This subroutine (in v2.1) constructs the intial conditions for the tracer fields
 !
 ! ==============================================================================================  !
 ! DECLARATIONS
   TYPE( HydrostaticPrimitive ), INTENT(inout) :: myDGSEM
   ! Local
   INTEGER    :: iS, iP, iQ, iEl, nS, nP, nQ, nEl
   REAL(prec) :: x, y, z, cn, An
   REAL(prec) :: sol(0:myDGSEM % nS,0:myDGSEM % nP, 0:myDGSEM % nQ, 1:myDGSEM % nEq)

      CALL myDGSEM % dgStorage % GetNumberOfNodes( nS, nP, nQ )
      nEl = myDGSEM % mesh % nElems
      
      sol = ZERO
      cn = 1.1623_prec
      An = 0.001_prec

      DO iEl = 1, nEl
         DO iQ = 0, nQ
            DO iP = 0, nP
               DO iS = 0, nS

                  CALL myDGSEM % mesh % GetPositionAtNode( iEl, x, y, z, iS, iP, iQ )
                  sol(iS,iP,iQ,3) = ZERO!z ! Buoyancy frequency of 1
               ENDDO
            ENDDO
         ENDDO

         CALL myDGSEM % SetBackgroundState( iEl, sol )
      ENDDO   

      sol = ZERO
      DO iEl = 1, nEl
         DO iQ = 0, nQ
            DO iP = 0, nP
               DO iS = 0, nS

                  CALL myDGSEM % mesh % GetPositionAtNode( iEl, x, y, z, iS, iP, iQ )
                  sol(iS,iP,iQ,1) = ZERO!An/cn*( sin(z/cn) - cos(z/cn)/cn )*exp( -HALF*( x-HALF )**2/(0.05_prec**2) )
                  sol(iS,iP,iQ,2) = ZERO
                  sol(iS,iP,iQ,3) = ZERO!An/cn*( -cos(z/cn) + sin(z/cn)/cn )*exp( -HALF*( x-HALF )**2/(0.05_prec**2) )
                  
               ENDDO
            ENDDO
         ENDDO

         CALL myDGSEM % SetSolution( iEl, sol )
      ENDDO
               

      DO iEl = 1, myDGSEM % freesurface % mesh % nElems
            DO iP = 0, nP
               DO iS = 0, nS

                  CALL myDGSEM % freesurface % mesh % GetPositionAtNode( iEl, x, y, iS, iP )
                  myDGSEM % freesurface % solution(iS,iP,iEl) = 0.01_prec*exp(-HALF*( (x-HALF)**2 + (y-HALF)**2 )/(0.05_prec**2))
                  
               ENDDO
            ENDDO
      ENDDO               
 END SUBROUTINE InitialCondition
!
!
!
END PROGRAM HydrostaticPrimitives_InitialConditions
