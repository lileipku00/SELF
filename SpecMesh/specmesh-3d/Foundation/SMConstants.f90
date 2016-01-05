!
! ////////////////////////////////////////////////////////////////////
!
!     SMConstants.F
!
!!
!!     Modification History:
!!       version 0.0 August 10, 2005 David A. Kopriva
!
!     MODULE SMConstants
!
!!        Defines constants for use by the spectral demonstaration
!!        routines, including precision definitions. 
!
!!    @author David A. Kopriva
!
!////////////////////////////////////////////////////////////////////////////////////////
!
      MODULE SMConstants
         INTEGER      , PARAMETER, PRIVATE:: DIGITS        = 15                      ! # of desired digits
         INTEGER      , PARAMETER, PRIVATE:: SINGLE_DIGITS = 6                       ! # of desired digits
         INTEGER      , PARAMETER         :: RP = SELECTED_REAL_KIND( DIGITS ) ! Real Kind
         INTEGER      , PARAMETER         :: SP = SELECTED_REAL_KIND( SINGLE_DIGITS ) ! Single Real Kind
         INTEGER      , PARAMETER         :: CP = SELECTED_REAL_KIND( DIGITS ) ! Complex Kind
         REAL(KIND=RP), PARAMETER         :: PI = 3.141592653589793238462643_RP
         
         INTEGER, PARAMETER               :: FORWARD  = +1
         INTEGER, PARAMETER               :: BACKWARD = -1
         
         INTEGER, PARAMETER               :: STD_OUT = 6
         INTEGER, PARAMETER               :: STD_IN  = 5
         
         COMPLEX(KIND=CP)                 :: ImgI =(0.0,1.0)! = SQRT(-1.0_RP)
         
      END MODULE SMConstants
