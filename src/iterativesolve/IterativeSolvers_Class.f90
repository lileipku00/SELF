! IterativeSolvers_Class.f90
! 
! Copyright 2015 Joseph Schoonover <schoonover.numerics@gmail.com>
! 
! IterativeSolvers_Class.f90 is part of the Spectral Element Libraries in Fortran (SELF).
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
 
 
MODULE IterativeSolvers_Class
! ========================================= Logs ================================================= !
!2016-05-11  Joseph Schoonover  schoonover.numerics@gmail.com 
!
! //////////////////////////////////////////////////////////////////////////////////////////////// ! 
!   The idea behind this module is to provide a set of iterative solvers that can be used to solve
!   Ax = b, without having to store the matrix "A", and to provide routines that can be reused
!   with the end-user determining the memory layout and data-structure organization that is appropriate
!   for their problem. The solution data, and the right-hand-side are stored in an arbitrary data 
!   structure (of the programmers choosing). The data-structure
!   must be a class that has routines called 
!      (1) MatrixAction -- compute Ax
!      (2) Residual -- computes r = b-Ax
!      (3) PreconditionSolve -- Optionally, a preconditioner can be provided to solve Hz = r, where
!                               H is the preconditioning matrix
!
! To accomplish this, an abstract data-type is provided here with the first two of the above listed
! procedures as "Deferred" procedures --> When the end-user wishes to use this module, these deferred
! procedures must be defined in the extended data type.
!
! ================================================================================================ !

USE ModelPrecision
USE ConstantsDictionary
USE CommonRoutines

USE IterativeSolversParams_Class

IMPLICIT NONE

  TYPE, ABSTRACT :: IterativeSolver
     INTEGER                 :: maxIters  ! Maximum number of iterates
     INTEGER                 :: nDOF      ! The number of Degrees of Freedom
     REAL(prec)              :: tolerance ! tolerance for convergence
     REAL(prec), ALLOCATABLE :: resi(:)   ! An array for storing the residual at each iterate
     REAL(prec), ALLOCATABLE :: sol(:)
     
     CONTAINS
     
     PROCEDURE :: Initialize => Initialize_IterativeSolver
     PROCEDURE :: Finallize => Finallize_IterativeSolver
     
     PROCEDURE :: SetMaxIters => SetMaxIters_IterativeSolver
     PROCEDURE :: GetMaxIters => GetMaxIters_IterativeSolver
     PROCEDURE :: SetNDOF => SetNDOF_IterativeSolver
     PROCEDURE :: GetNDOF => GetNDOF_IterativeSolver
     PROCEDURE :: SetTolerance => SetTolerance_IterativeSolver
     PROCEDURE :: GetTolerance => GetTolerance_IterativeSolver
     
     PROCEDURE :: WriteResidual => WriteResidual_IterativeSolver
     
     PROCEDURE (ActionOfMatrix), DEFERRED :: MatrixAction
     PROCEDURE (BminusAx), DEFERRED       :: Residual
     PROCEDURE (CopyFromType), DEFERRED   :: CopyFrom 
     PROCEDURE (CopyToType), DEFERRED     :: CopyTo 
     
  END TYPE IterativeSolver

  ABSTRACT INTERFACE
     FUNCTION ActionOfMatrix( this, s )
        USE ModelPrecision
        IMPORT IterativeSolver
        CLASS(IterativeSolver) :: this
        REAL(prec)             :: s(1:this % nDOF)
        REAL(prec)             :: ActionOfMatrix(1:this % nDOF)
     END FUNCTION ActionOfMatrix
  END INTERFACE
  
  ABSTRACT INTERFACE
     FUNCTION BminusAx( this, s )
        USE ModelPrecision
        IMPORT IterativeSolver
        CLASS(IterativeSolver) :: this
        REAL(prec)             :: s(1:this % nDOF)
        REAL(prec)             :: BminusAx(1:this % nDOF)
     END FUNCTION BminusAx
  END INTERFACE

  ABSTRACT INTERFACE
     SUBROUTINE CopyToType( this, sol )
        USE ModelPrecision
        IMPORT IterativeSolver
        CLASS(IterativeSolver) :: this
        REAL(prec)             :: sol(1:this % nDOF)
     END SUBROUTINE CopyToType
  END INTERFACE

  ABSTRACT INTERFACE
     SUBROUTINE CopyFromType( this, sol )
        USE ModelPrecision
        IMPORT IterativeSolver
        CLASS(IterativeSolver) :: this
        REAL(prec)             :: sol(1:this % nDOF)
     END SUBROUTINE CopyFromType
  END INTERFACE

! //////////////////// Conjugate Gradient ////////////////////////// !

  TYPE, ABSTRACT, EXTENDS(IterativeSolver) :: ConjugateGradient
     CONTAINS
     PROCEDURE :: Solve => Solve_ConjugateGradient
  END TYPE ConjugateGradient

! ////////////////////////////////////////////////////////////////// !

! ///////////// Pre-Conditioned ConjugateGradient ////////////////// !

  TYPE, ABSTRACT, EXTENDS(IterativeSolver) :: PCConjugateGradient
     INTEGER :: mInnerIters
     CONTAINS
     PROCEDURE :: Solve => Solve_PCConjugateGradient
 
     PROCEDURE (InvertThePreconditionerCG), DEFERRED :: PreConditionInvert  
  END TYPE PCConjugateGradient


! ////////////////////////////////////////////////////////////////// !

! /////////////////////////// GMRES //////////////////////////////// !

  TYPE, ABSTRACT, EXTENDS(IterativeSolver) :: GMRES
     INTEGER :: mInnerIters
     CONTAINS
     PROCEDURE :: Solve => Solve_GMRES
  END TYPE GMRES

! ////////////////////////////////////////////////////////////////// !


! ////////////////// Pre-Conditioned GMRES ///////////////////////// !

  TYPE, ABSTRACT, EXTENDS(IterativeSolver) :: PCGMRES
     INTEGER :: mInnerIters
     CONTAINS
     PROCEDURE :: Solve => Solve_PCGMRES
 
     PROCEDURE (InvertThePreconditionerGM), DEFERRED :: PreConditionInvert  
  END TYPE PCGMRES


! ////////////////////////////////////////////////////////////////// !


  ABSTRACT INTERFACE
     FUNCTION InvertThePreconditionerCG( this, s )
        USE ModelPrecision
        IMPORT PCConjugateGradient
        CLASS(PCConjugateGradient) :: this
        REAL(prec)                 :: s(1:this % nDOF)
        REAL(prec)                 :: InvertThePreconditionerCG(1:this % nDOF)
     END FUNCTION InvertThePreconditionerCG
  END INTERFACE

  ABSTRACT INTERFACE
     FUNCTION InvertThePreconditionerGM( this, s )
        USE ModelPrecision
        IMPORT PCGMRES
        CLASS(PCGMRES) :: this
        REAL(prec)     :: s(1:this % nDOF)
        REAL(prec)     :: InvertThePreconditionerGM(1:this % nDOF)
     END FUNCTION InvertThePreconditionerGM
  END INTERFACE
 CONTAINS
!
!
!==================================================================================================!
!------------------------------- Manual Constructors/Destructors ----------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE Initialize_IterativeSolver( this, params )
 ! S/R Initialize
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ), INTENT(out)       :: this
   TYPE( IterativeSolversParams ), INTENT(in)  :: params
   
      this % maxIters  = params % MaximumIterates
      this % nDOF      = params % nDOF
      this % tolerance = params % tolerance
      
      ALLOCATE( this % sol(1:this % nDOF), this % resi(0:this % maxIters) )
      this % sol  = ZERO
      this % resi = ZERO
      
 END SUBROUTINE Initialize_IterativeSolver
!
!
!
 SUBROUTINE Finallize_IterativeSolver( this )
 ! S/R Finallize
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ), INTENT(inout) :: this
      
    DEALLOCATE( this % sol, this % resi )
      
 END SUBROUTINE Finallize_IterativeSolver
!
!
!==================================================================================================!
!------------------------------------------- Accessors --------------------------------------------!
!==================================================================================================!
!
! 
 SUBROUTINE SetMaxIters_IterativeSolver( this, mI )
 ! S/R SetMaxIters
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ), INTENT(inout) :: this
   INTEGER, INTENT(in)                      :: mI
   
    this % maxIters = mI
    
 END SUBROUTINE SetMaxIters_IterativeSolver
!
!
!
 FUNCTION GetMaxIters_IterativeSolver( this ) RESULT( mI )
 ! FUNCTION GetMaxIters
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ) :: this
   INTEGER                   :: mI
   
    mI = this % maxIters 
    
 END FUNCTION GetMaxIters_IterativeSolver
!
!
!
 SUBROUTINE SetNDOF_IterativeSolver( this, n )
 ! S/R SetNDOF
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ), INTENT(inout) :: this
   INTEGER, INTENT(in)                      :: n
   
    this % nDOF = n
    
 END SUBROUTINE SetNDOF_IterativeSolver
!
!
!
 FUNCTION GetNDOF_IterativeSolver( this ) RESULT( n )
 ! FUNCTION GetNDOF
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ) :: this
   INTEGER                   :: n
   
    n = this % nDOF
    
 END FUNCTION GetNDOF_IterativeSolver
!
!
!
 SUBROUTINE SetTolerance_IterativeSolver( this, tol )
 ! S/R SetTolerance
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ), INTENT(inout) :: this
   REAL(prec), INTENT(in)                  :: tol
   
    this % tolerance = tol
    
 END SUBROUTINE SetTolerance_IterativeSolver
!
!
!
 FUNCTION GetTolerance_IterativeSolver( this ) RESULT( tol )
 ! FUNCTION GetTolerance
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ) :: this
   REAL(prec)                :: tol
   
    tol = this % Tolerance 
    
 END FUNCTION GetTolerance_IterativeSolver
!
!
!==================================================================================================!
!----------------------------------------- Type Specific ------------------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE Solve_ConjugateGradient( this, ioerr )
 !  S/R Solve
 !
 !  This subroutine solves the system Ax = b using the un-preconditioned conjugate gradient method.
 !  The matrix action and residual routines are supplied by a non-abstracted type-extension of
 !  ConjugateGradient. These routines should return an array indexed from 1 to nDOF. Thus,
 !  in addition to a MatrixAction and Residual, the user should map their data-structure to a 1-D 
 !  array.  
 !
 !  On output ioerr is set to an error checking flag. 
 !  If ioerr ==  0, the method converged within the maximum number of iterations.
 !     ioerr == -1, the method did not converge within the maximum number of iterations.
 !     ioerr == -2, something that is not caught by the current construct happened.
 !  
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( ConjugateGradient ), INTENT(inout) :: this
   INTEGER, INTENT(out)                      :: ioerr
   ! LOCAL
   INTEGER    :: iter
   INTEGER    :: nIt
   REAL(prec) :: TOL
   REAL(prec) :: r(1:this % nDOF )
   REAL(prec) :: v(1:this % nDOF )
   REAL(prec) :: z(1:this % nDOF )
   REAL(prec) :: rNorm
   REAL(prec) :: a, b, num, den, r0
   
      ioerr = -2
      nIt = this % maxIters
      TOL = this % tolerance
      
      CALL this % CopyTo( this % sol ) ! Copy the data-structure to the array "this % sol"
      r = this % Residual( this % sol )
      r0 = sqrt( DOT_PRODUCT( r, r ) ) 
      
      this % resi = ZERO
      this % resi(0) = r0
 
      DO iter = 1,nIt ! Loop over the CG iterates

         num = DOT_PRODUCT( r, r )

         IF( iter == 1) THEN
            v = r
         ELSE
            b = num/den
            v = r + b*v
         ENDIF

         z = this % MatrixAction( v )
         a = num/DOT_PRODUCT( v, z )
         this % sol = this % sol + a*v
         r = r - a*z
         
         den = num

         rNorm = sqrt( DOT_PRODUCT(r,r) )
         this % resi(iter) = rNorm
         IF( sqrt(rNorm)/r0 < TOL ) then
           EXIT
           ioerr = 0
         ENDIF

      ENDDO ! iter, loop over the CG iterates 

      ! Copy the array storage back to the native storage for file I/O
      CALL this % CopyFrom( this % sol )


      IF( SQRT(rNorm) > TOL )THEN
         PRINT*, 'MODULE IterativeSolvers : ConjugateGradient failed to converge '
         PRINT*, 'Last L-2 residual : ', sqrt(rNorm)
         ioerr=-1
      ENDIF   

 END SUBROUTINE Solve_ConjugateGradient
!
!
!
SUBROUTINE Solve_PCConjugateGradient( this, ioerr )
 !  S/R Solve
 !
 !  This subroutine solves the system Ax = b using the preconditioned conjugate gradient method.
 !  The matrix action, residual, preconditioning routines are supplied by a non-abstracted 
 !  type-extension of PCConjugateGradient. These routines should return an array indexed from 1 to 
 !  nDOF. Thus, in addition to a MatrixAction and Residual, the user should map their data-structure
 !  to a 1-D array.  
 !
 !  On output ioerr is set to an error checking flag. 
 !  If ioerr ==  0, the method converged within the maximum number of iterations.
 !     ioerr == -1, the method did not converge within the maximum number of iterations.
 !     ioerr == -2, something that is not caught by the current construct happened.
 !  
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( PCConjugateGradient ), INTENT(inout) :: this
   INTEGER, INTENT(out)                        :: ioerr
   ! LOCAL
   INTEGER    :: iter
   INTEGER    :: nIt
   REAL(prec) :: TOL
   REAL(prec) :: r(1:this % nDOF )
   REAL(prec) :: v(1:this % nDOF )
   REAL(prec) :: z(1:this % nDOF )
   REAL(prec) :: w(1:this % nDOF )
   REAL(prec) :: rNorm
   REAL(prec) :: a, b, num, den, r0
   
      ioerr = -2
      nIt = this % maxIters
      TOL = this % tolerance
      
      CALL this % CopyTo( this % sol ) ! Copy the data-structure to the array "this % sol"
      r = this % Residual( this % sol )
      r0 = sqrt( DOT_PRODUCT( r, r ) ) 
      
      this % resi = ZERO
      this % resi(0) = r0
 
      DO iter = 1,nIt ! Loop over the CG iterates
 
         w = this % PreConditionInvert( r )

         num = DOT_PRODUCT( r, w )

         IF( iter == 1) THEN
            v = w
         ELSE
            b = num/den
            v = w + b*v
         ENDIF

         z = this % MatrixAction( v )
         a = num/DOT_PRODUCT( v, z )
         this % sol = this % sol + a*v
         r = r - a*z
         
         den = num

         rNorm = sqrt( DOT_PRODUCT(r,r) )
         this % resi(iter) = rNorm
         IF( sqrt(rNorm)/r0 < TOL ) then
           EXIT
           ioerr = 0
         ENDIF

      ENDDO ! iter, loop over the CG iterates 

      ! Copy the array storage back to the native storage for file I/O
      CALL this % CopyFrom( this % sol )


      IF( SQRT(rNorm) > TOL )THEN
         PRINT*, 'MODULE IterativeSolvers : ConjugateGradient failed to converge '
         PRINT*, 'Last L-2 residual : ', sqrt(rNorm)
         ioerr=-1
      ENDIF   

 END SUBROUTINE Solve_PCConjugateGradient
!
!
!
 SUBROUTINE Solve_GMRES( this, ioerr )
 !  S/R Solve
 !
 !  This subroutine solves the system Ax = b using the un-preconditioned GMRES.
 !  The matrix action and residual routines are supplied by a non-abstracted type-extension of
 !  GMRES. These routines should return an array indexed from 1 to nDOF. Thus,
 !  in addition to a MatrixAction and Residual, the user should map their data-structure to a 1-D 
 !  array.  
 !
 !  On output ioerr is set to an error checking flag. 
 !  If ioerr ==  0, the method converged within the maximum number of iterations.
 !     ioerr == -1, the method did not converge within the maximum number of iterations.
 !     ioerr == -2, something that is not caught by the current construct happened.
 !  
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( GMRES ), INTENT(inout) :: this
   INTEGER, INTENT(out)                      :: ioerr
   ! LOCAL
   INTEGER    :: i, j, k, l
   INTEGER    :: nIt, m, nr 
   REAL(prec) :: TOL
   REAL(prec) :: r(1:this % nDOF )
   REAL(prec) :: v(1:this % nDOF, 1:this % mInnerIters+1)
   REAL(prec) :: w(1:this % nDOF )
   REAL(prec) :: rho(1:this % mInnerIters, 1:this % mInnerIters)
   REAL(prec) :: h(1:this % mInnerIters+1, 1:this % mInnerIters)
   REAL(prec) :: c(1:this % mInnerIters), s(1:this % mInnerIters), bhat(1:this % mInnerIters+1)
   REAL(prec) :: y(1:this % mInnerIters+1)
   REAL(prec) :: b, d, g, r0, rc
   
      ioerr = -2
      nIt = this % maxIters
      m   = this % mInnerIters
      TOL = this % tolerance
      
      CALL this % CopyTo( this % sol ) ! Copy the data-structure to the array "this % sol"
      r = this % Residual( this % sol )
      r0 = sqrt( DOT_PRODUCT( r, r ) )
     
      l = 0 
      this % resi = ZERO
      this % resi(l) = r0
      
      v    = ZERO  
      rho  = ZERO
      bhat = ZERO 
      s    = ZERO
      c    = ZERO
      y    = ZERO
   
     
      DO j = 1,nIt

         b       = sqrt( DOT_PRODUCT( r, r ) )
         v(:,1)  = r/b
         bhat(1) = b

         DO i = 1, m
            l = l+1
            nr = i
            ! The first step in GMRES is to build the orthogonal basis up to order "i"
            ! with the accompanying upper hessenburg matrix.
            w = this % MatrixAction( v(:,i) )
            
            ! The new basis vector is obtained by multiplying the previous basis vector by the matrix
            ! and orthogonalizing wrt to all of the previous basis vectors using a Gram-Schmidt process.
            DO k = 1, i
               h(k,i) = DOT_PRODUCT( v(:,k), w )
               w      = w - h(k,i)*v(:,k)
            ENDDO

            h(i+1,i) = sqrt( DOT_PRODUCT(w,w) )

            IF( AlmostEqual( h(i+1,i), ZERO )  )THEN
               EXIT
            ENDIF

            v(:,i+1) = w/h(i+1,i)
            rho(1,i) = h(1,i)

            ! Givens rotations are applied to the upper hessenburg matrix and to the residual vectors
            ! that are formed from the orthogonalization process. Here, they are done "on-the-fly"
            ! as opposed to building the entire upper hessenburg matrix and orthonormal basis
            ! before performing the rotations. This way, we can also tell if we have found an exact
            ! solution ( if h(i+1,i) = 0 ) with a smaller subspace than size m.
            DO k = 2, i

               g          = c(k-1)*rho(k-1,i) + s(k-1)*h(k,i)
               rho(k,i)   = -s(k-1)*rho(k-1,i) + c(k-1)*h(k,i)
               rho(k-1,i) = g 

            ENDDO

            ! Here the coefficients of the Givens rotation matrix are computed
            d = sqrt( rho(i,i)**2 + h(i+1,i)**2 )
            c(i) = rho(i,i)/d
            s(i) = h(i+1,i)/d

            rho(i,i) = c(i)*rho(i,i) + s(i)*h(i+1,i)
            ! And applied to the residual vector
            bhat(i+1) = -s(i)*bhat(i)
            bhat(i)   = c(i)*bhat(i)
 
         
            rc = abs( bhat(i+1) )

            this % resi(l) = rc
            
            IF( rc/r0 <= TOL )THEN
               EXIT
            ENDIF

         ENDDO
         
         IF( rc/r0 > TOL )THEN
            nr = m
         ENDIF

         ! Back-substitution of the tridiagonal matrix that resulted from the rotations
         y(nr) = bhat(nr)/rho(nr,nr)
         DO k = nr-1, 1, -1

            y(k) = bhat(k)

            DO i = k+1, nr
               y(k) = y(k) - rho(k,i)*y(i)

            ENDDO

            y(k) = y(k)/rho(k,k)

         ENDDO
         
 
         DO k = 1,this % nDOF
            this % sol(k) = this % sol(k) + DOT_PRODUCT( v(k, 1:nr), y(1:nr) )
         ENDDO

         IF( rc/r0 <= TOL )THEN
            ioerr = 0
            EXIT
         ENDIF

         r = this % Residual( this % sol )

      ENDDO 

      ! Copy the array storage back to the native storage for file I/O
      CALL this % CopyFrom( this % sol )


      IF( rc/r0 > TOL )THEN
         PRINT*, 'MODULE IterativeSolvers : GMRES failed to converge '
         PRINT*, 'Last L-2 residual : ', sqrt(DOT_PRODUCT(r,r))
         ioerr=-1
      ENDIF   

 END SUBROUTINE Solve_GMRES
!
!
!
 SUBROUTINE Solve_PCGMRES( this, ioerr )
 !  S/R Solve
 !
 !  This subroutine solves the system Ax = b using the preconditioned GMRES.
 !  The matrix action, residual, and preconditioning routines are supplied by a non-abstracted 
 !  type-extension of PCGMRES. These routines should return an array indexed from 1 to 
 !  nDOF. Thus, in addition to a MatrixAction and Residual, the user should map their data-structure
 !  to a 1-D array so that communication to this routine is possible.  
 !
 !  The flavor of GMRES implemented here is the "Flexible GMRES with variable right preconditioning".
 !  See pp.74-76 of "Iterative Krylov Methods for Large Linear Systems" by Henk A. van der Vorst
 !
 !  On output ioerr is set to an error checking flag. 
 !  If ioerr ==  0, the method converged within the maximum number of iterations.
 !     ioerr == -1, the method did not converge within the maximum number of iterations.
 !     ioerr == -2, something that is not caught by the current construct happened.
 !  
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( PCGMRES ), INTENT(inout) :: this
   INTEGER, INTENT(out)            :: ioerr
   ! LOCAL
   INTEGER    :: i, j, k, l
   INTEGER    :: nIt, m, nr 
   REAL(prec) :: TOL
   REAL(prec) :: r(1:this % nDOF)
   REAL(prec) :: v(1:this % nDOF, 1:this % mInnerIters+1)
   REAL(prec) :: w(1:this % nDOF)
   REAL(prec) :: z(1:this % nDOF, 1:this % mInnerIters+1)
   REAL(prec) :: rho(1:this % mInnerIters, 1:this % mInnerIters)
   REAL(prec) :: h(1:this % mInnerIters+1, 1:this % mInnerIters)
   REAL(prec) :: c(1:this % mInnerIters), s(1:this % mInnerIters), bhat(1:this % mInnerIters+1)
   REAL(prec) :: y(1:this % mInnerIters+1)
   REAL(prec) :: b, d, g, r0, rc
   
      ioerr = -2
      nIt = this % maxIters
      m   = this % mInnerIters
      TOL = this % tolerance
      
      CALL this % CopyTo( this % sol ) ! Copy the data-structure to the array "this % sol"
      r = this % Residual( this % sol )
      r0 = sqrt( DOT_PRODUCT( r, r ) )
     
      l = 0 
      this % resi = ZERO
      this % resi(l) = r0
      
      v    = ZERO  
      rho  = ZERO
      bhat = ZERO 
      s    = ZERO
      c    = ZERO
      y    = ZERO
   
     
      DO j = 1,nIt

         b       = sqrt( DOT_PRODUCT( r, r ) )
         v(:,1)  = r/b
         bhat(1) = b

         DO i = 1, m
            l = l+1
            nr = i

            ! Applying the precondtioner 
            z(:,i) = this % PreconditionInvert( v(:,i) )
            ! The first step in GMRES is to build the orthogonal basis up to order "i"
            ! with the accompanying upper hessenburg matrix.
            w = this % MatrixAction( z(:,i) )
            
            ! The new basis vector is obtained by multiplying the previous basis vector by the matrix
            ! and orthogonalizing wrt to all of the previous basis vectors using a Gram-Schmidt process.
            DO k = 1, i
               h(k,i) = DOT_PRODUCT( v(:,k), w )
               w      = w - h(k,i)*v(:,k)
            ENDDO

            h(i+1,i) = sqrt( DOT_PRODUCT(w,w) )

            IF( AlmostEqual( h(i+1,i), ZERO )  )THEN
               EXIT
            ENDIF

            v(:,i+1) = w/h(i+1,i)
            rho(1,i) = h(1,i)

            ! Givens rotations are applied to the upper hessenburg matrix and to the residual vectors
            ! that are formed from the orthogonalization process. Here, they are done "on-the-fly"
            ! as opposed to building the entire upper hessenburg matrix and orthonormal basis
            ! before performing the rotations. This way, we can also tell if we have found an exact
            ! solution ( if h(i+1,i) = 0 ) with a smaller subspace than size m.
            DO k = 2, i

               g          = c(k-1)*rho(k-1,i) + s(k-1)*h(k,i)
               rho(k,i)   = -s(k-1)*rho(k-1,i) + c(k-1)*h(k,i)
               rho(k-1,i) = g 

            ENDDO

            ! Here the coefficients of the Givens rotation matrix are computed
            d = sqrt( rho(i,i)**2 + h(i+1,i)**2 )
            c(i) = rho(i,i)/d
            s(i) = h(i+1,i)/d

            rho(i,i) = c(i)*rho(i,i) + s(i)*h(i+1,i)
            ! And applied to the residual vector
            bhat(i+1) = -s(i)*bhat(i)
            bhat(i)   = c(i)*bhat(i)
 
         
            rc = abs( bhat(i+1) )

            this % resi(l) = rc
            
            IF( rc/r0 <= TOL )THEN
               EXIT
            ENDIF

         ENDDO
         
         IF( rc/r0 > TOL )THEN
            nr = m
         ENDIF

         ! Back-substitution of the tridiagonal matrix that resulted from the rotations
         y(nr) = bhat(nr)/rho(nr,nr)
         DO k = nr-1, 1, -1

            y(k) = bhat(k)

            DO i = k+1, nr
               y(k) = y(k) - rho(k,i)*y(i)

            ENDDO

            y(k) = y(k)/rho(k,k)

         ENDDO
         
 
         DO k = 1,this % nDOF
            this % sol(k) = this % sol(k) + DOT_PRODUCT( z(k, 1:nr), y(1:nr) )
         ENDDO

         IF( rc/r0 <= TOL )THEN
            ioerr = 0
            EXIT
         ENDIF

         r = this % Residual( this % sol )

      ENDDO 

      ! Copy the array storage back to the native storage for file I/O
      CALL this % CopyFrom( this % sol )


      IF( rc/r0 > TOL )THEN
         PRINT*, 'MODULE IterativeSolvers : GMRES failed to converge '
         PRINT*, 'Last L-2 residual : ', sqrt(DOT_PRODUCT(r,r))
         ioerr=-1
      ENDIF   

 END SUBROUTINE Solve_PCGMRES
!
!
!==================================================================================================!
!------------------------------------------- File I/O ---------------------------------------------!
!==================================================================================================!
!
!
 SUBROUTINE WriteResidual_IterativeSolver( this, rFile )
 ! S/R WriteResidual
 !
 ! =============================================================================================== !
 ! DECLARATIONS
   IMPLICIT NONE
   CLASS( IterativeSolver ), INTENT(in) :: this
   CHARACTER(*), INTENT(in), OPTIONAL    :: rFile
   ! LOCAL
   INTEGER        :: n, i, fUnit
   CHARACTER(100) :: localFile
    
    n = this % GetMaxIters( )
    
    IF( PRESENT(rFile) )THEN
       localFile = rFile
    ELSE
       localFile = 'residual.curve'
    ENDIF
    
    OPEN( UNIT = NewUnit(fUnit), &
          FILE = TRIM(localFile), &
          FORM = 'FORMATTED' )
    WRITE( fUnit, * ) '#residual'
    DO i = 0, n
       WRITE(fUnit,'(I4,1x,E17.8)') i, this % resi(i)
    ENDDO

    CLOSE(UNIT = fUnit)   
   
 END SUBROUTINE WriteResidual_IterativeSolver
 
END MODULE IterativeSolvers_Class
