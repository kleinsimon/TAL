#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double *S, *s, *r;
  mwSize n1, n2, i1, i2, k;
  int r1;

    S  = mxGetPr(prhs[0]);
    n1 = mxGetM(prhs[0]);
    n2 = mxGetN(prhs[0]);
    s  = mxGetPr(prhs[1]);  
    r  = mxGetPr(prhs[2]);
    r1 = (int) r[0] - 1;

    for (i1 = 0; i1 < n1; i1++) {
       k = i1;
       for (i2 = 0; i2 < n2; i2++) {
          if (i2 > r1) {
              k += n1;
              continue;
          }
          if (S[k] != s[i2]) {
             break;
          }
          k += n1;
       }

       if (i2 == n2) {  // Matching row found:
          plhs[0] = mxCreateDoubleScalar((double) (i1 + 1));
          return;
       }
    }

    // No success:
    plhs[0] = mxCreateDoubleScalar(mxGetNaN());
  }