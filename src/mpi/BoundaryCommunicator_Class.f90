MODULE BoundaryCommunicator2D_Class
! BoundaryCommunicator2D_Class.f90
!
! schoonover.numerics@gmail.com
!
! o (ver 2.1) Dec 2015
!
!
! 
!  
! ================================================================================================ !

! src/common/
USE ModelPrecision
USE ConstantsDictionary
USE ModelFlags
USE CommonRoutines


IMPLICIT NONE
     
    TYPE BoundaryCommunicator2D
      INTEGER                               :: nEq, nS, nP, nBoundaryEdges

      INTEGER, ALLOCATABLE                  :: extElemIDs(:), extProcIDs(:)
      INTEGER, ALLOCATABLE                  :: boundaryEdgeIDs(:)
      REAL(prec), ALLOCATABLE               :: externalState(:,:,:) ! (0:nS,1:nEq,1:boundaryEdges)
      REAL(prec), ALLOCATABLE               :: prescribedState(:,:,:)

      CONTAINS

      PROCEDURE :: Build => Build_BoundaryCommunicator2D
      PROCEDURE :: Trash => Trash_BoundaryCommunicator2D
      
       ! Type Specific Routines
      PROCEDURE :: ReadPickup  => ReadPickup_BoundaryCommunicator2D
      PROCEDURE :: WritePickup => WritePickup_BoundaryCommunicator2D

    END TYPE BoundaryCommunicator2D



 CONTAINS
!
!
!==================================================================================================!
!------------------------------- Manual Constructors/Destructors ----------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE Build_BoundaryCommunicator2D( myBC, nS, nP, nEq, nBe )
 ! S/R Build
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(BoundaryCommunicator2D), INTENT(inout) :: myBC
   INTEGER, INTENT(in)                        :: nS, nP, nEq, nBe

      myBC % nS             = nS
      myBC % nP             = nP
      myBC % nEq            = nEq
      myBC % nBoundaryEdges = nBe

      ALLOCATE( myBC % extElemIDS(1:nBe), myBC % extProcIDs(1:nBe) )
      ALLOCATE( myBC % boundaryEdgeIDs(1:nBe) )
      ALLOCATE( myBC % externalState(0:nS,1:nEq,1:nBe) )
      ALLOCATE( myBC % prescribedState(0:nS,1:nEq,1:nBe) )

      myBC % extElemIDs      = 0
      myBC % extProcIDs      = 0
      myBC % boundaryEdgeIDs = 0
      myBC % externalState   = ZERO 
      myBC % prescribedState = ZERO

 END SUBROUTINE Build_BoundaryCommunicator2D
!
!
!
 SUBROUTINE Trash_BoundaryCommunicator2D( myBC )
 ! S/R Trash
 ! 
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS(BoundaryCommunicator2D), INTENT(inout) :: myBC

     DEALLOCATE( myBC % boundaryEdgeIDs, myBC % externalState )
     DEALLOCATE( myBC % prescribedState )
     DEALLOCATE( myBC % externalState )
     DEALLOCATE( myBC % prescribedState )

 END SUBROUTINE Trash_BoundaryCommunicator2D
!
!
!==================================================================================================!
!--------------------------------------- Accessors ------------------------------------------------!
!==================================================================================================!
!
!
!
!
!==================================================================================================!
!--------------------------------- Type Specific Routines -----------------------------------------!
!==================================================================================================!
!
!
!
!
!==================================================================================================!
!-------------------------------------- FILE I/O ROUTINES -----------------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE WriteConnectivity_BoundaryCommunicator2D( myBC, rank )
 ! S/R WriteConnectivity
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( BoundaryCommunicator2D ), INTENT(in) :: myBC
   INTEGER, INTENT(in)                         :: rank
  ! LOCAL
   CHARACTER(4)  :: rankChar
   INTEGER       :: iEdgefUnit
   INTEGER       :: nS, nP

      nS = myBC % nS
      nP = myBC % nP
     
      WRITE(rankChar,'(I4.4)') rank

      OPEN( UNIT=NEWUNIT(fUnit), &
            FILE= 'connectivity.'//rankChar//'.bcom2d', &
            FORM='formatted',&
            ACCESS='sequential',&
            STATUS='replace',&
            ACTION='WRITE' )

      WRITE( fUnit, * ) nS, nP, myBC % nEq, myBC % nBoundaryEdges
      DO iEdge = 1, myBC % nBoundaryEdges

         WRITE( fUnit, * ) myBC % boundaryEdgeIDs(iEdge), &
                           myBC % extElemIDs(iEdge), &
                           myBC % extProcIDs(iEdge)

      ENDDO 

      CLOSE(fUnit)


 END SUBROUTINE WriteConnectivity_BoundaryCommunicator2D
!
!
!
 SUBROUTINE ReadConnectivity_BoundaryCommunicator2D( myBC, rank )
 ! S/R ReadConnectivity
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( BoundaryCommunicator2D ), INTENT(inout) :: myBC
   INTEGER, INTENT(in)                            :: rank
  ! LOCAL
   CHARACTER(4)  :: rankChar
   INTEGER       :: iEdge
   INTEGER       :: fUnit
   INTEGER       :: nS, nP, nEq, nBe

      READ(rankChar,'(I4.4)') rank

      OPEN( UNIT=NEWUNIT(fUnit), &
            FILE= 'connectivity.'//rankChar//'.bcom2d', &
            FORM='formatted',&
            ACCESS='sequential',&
            STATUS='OLD',&
            ACTION='READ' )

      READ( fUnit, * ) nS, nP, nEq, nBe

      CALL myBC % Build( nS, nP, nEq, nBe )

      DO iEdge = 1, myBC % nBoundaryEdges

         READ( fUnit, * ) myBC % boundaryEdgeIDs(iEdge), &
                           myBC % extElemIDs(iEdge), &
                           myBC % extProcIDs(iEdge)

      ENDDO 

      CLOSE(fUnit)


 END SUBROUTINE ReadConnectivity_BoundaryCommunicator2D
!
!
!
 SUBROUTINE WritePickup_BoundaryCommunicator2D( myBC, filename, rank )
 ! S/R WritePickup
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( BoundaryCommunicator2D ), INTENT(in) :: myBC
   CHARACTER(*), INTENT(in)                    :: filename
   INTEGER, INTENT(in)                         :: rank
  ! LOCAL
   CHARACTER(4)  :: rankChar
   INTEGER       :: iEdge
   INTEGER       :: thisRec, fUnit
   INTEGER       :: iS, iP, iEq, nS, nP

      nS = myBC % nS
      nP = myBC % nP
     
      WRITE(rankChar,'(I4.4)') rank

      OPEN( UNIT=NEWUNIT(fUnit), &
            FILE=TRIM(filename)//'.'//rankChar//'.pickup', &
            FORM='unformatted',&
            ACCESS='direct',&
            STATUS='replace',&
            ACTION='WRITE',&
            CONVERT='big_endian',&
            RECL=prec*(nS+1)*nSWeq )

      thisRec = 1 
      DO iEdge = 1, myBC % nBoundaryEdges
         WRITE( fUnit, REC=thisRec ) myBC % prescribedState(:,:,iEl)
         thisRec = thisRec+1
      ENDDO
      CLOSE(UNIT=fUnit)



 END SUBROUTINE WritePickup_BoundaryCommunicator2D
!
!
!
 SUBROUTINE ReadPickup_BoundaryCommunicator2D( myBC, filename, rank )
 ! S/R ReadPickup
 ! 
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( BoundaryCommunicator2D ), INTENT(inout) :: myBC
   CHARACTER(*), INTENT(in)                       :: filename
   INTEGER, INTENT(in)                            :: rank
  ! LOCAL
   CHARACTER(4)  :: rankChar
   INTEGER       :: iEdge
   INTEGER       :: thisRec, fUnit
   INTEGER       :: iS, iP, iEq, nS, nP, nEq, nBe

      READ(rankChar,'(I4.4)') rank

      OPEN( UNIT=NEWUNIT(fUnit), &
            FILE=TRIM(filename)//'.'//rankChar//'.pickup', &
            FORM='unformatted',&
            ACCESS='direct',&
            STATUS='OLD',&
            ACTION='READ',&
            CONVERT='big_endian',&
            RECL=prec*(nS+1)*nSWeq )

      thisRec = 1 
      DO iEdge = 1, myBC % nBoundaryEdges
         READ( fUnit, REC=thisRec ) myBC % prescribedState(:,:,iEl)
         thisRec = thisRec+1
      ENDDO
      CLOSE(UNIT=fUnit)


 END SUBROUTINE ReadPickup_BoundaryCommunicator2D
!
!
!
 END MODULE BoundaryCommunicator2D_Class



