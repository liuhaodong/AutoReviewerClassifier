%
% Adaptation of matlab's pinv function to use our fastSVD code
%
%
% WARNING: doesn't work yet
%

function X = compute_pinv(A,varargin)
%PINV   Pseudoinverse.
%   X = PINV(A) produces a matrix X of the same dimensions
%   as A' so that A*X*A = A, X*A*X = X and A*X and X*A
%   are Hermitian. The computation is based on SVD(A) and any
%   singular values less than a tolerance are treated as zero.
%   The default tolerance is MAX(SIZE(A)) * NORM(A) * EPS.
%
%   PINV(A,TOL) uses the tolerance TOL instead of the default.
%
%   Class support for input A:
%      float: double, single
%
%   See also RANK.
 
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.12.4.1 $  $Date: 2004/03/02 21:47:30 $
 
[m,n] = size(A);
if n > m
   X = pinv(A',varargin{:})';
else
   [U,S,V] = compute_fastSVD(A);
   if m > 1, s = diag(S);
      elseif m == 1, s = S(1);
      else s = 0;
   end
   if nargin == 2
      tol = varargin{1};
   else
      tol = max(m,n) * myeps(max(s));
   end
   r = sum(s > tol);
   if (r == 0)
      X = zeros(size(A'),class(A));
   else
      s = diag(ones(r,1)./s(1:r));
      X = V(:,1:r)*s*U(:,1:r)';
   end
end


function [] = test_this()


function [r] = myeps(x)

E = floor(log2(x));
if isa(x,'single')
     r = 2^(E-23);
elseif isa(x,'double')
     r = 2^(E-52);
else
error('myeps: argument must be a single or a double');
end
