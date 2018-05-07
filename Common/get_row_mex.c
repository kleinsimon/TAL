#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double *A, *r;
  mwSize n1, n2, i1, i2;
  int r1;

    A  = mxGetPr(prhs[0]);
    n1 = mxGetM(prhs[0]);
    n2 = mxGetN(prhs[0]);
    r  = mxGetPr(prhs[2]);
    r1 = (int) r[0] - 1;

    if (r1 < n1) { 
      plhs[0] = mxCreateDoubleScalar((double) (A[r1*n2]));
      return;
    }

    // No success:
    plhs[0] = mxCreateDoubleScalar(mxGetNaN());
  }