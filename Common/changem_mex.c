#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *A, *N, *O;
	mwSize a1, a2, n1, n2, o1, o2;
    int i1, i2;
  
    A  = mxGetPr(prhs[0]);
    N  = mxGetPr(prhs[1]);  
    O  = mxGetPr(prhs[2]);
    
    a1 = mxGetM(prhs[0]);
    a2 = mxGetN(prhs[0]);
    
    n1 = mxGetM(prhs[1]);
    n2 = mxGetN(prhs[1]);
    
    o1 = mxGetM(prhs[2]);
    o2 = mxGetN(prhs[2]);

    for (i1 = 0; i1 < a1; i1++) {
        for (i2 = 0; i2 < n1; i2++) {
            if (A[i1]==O[i2]) {
                A[i1]==N[i2];
                break;
            }
        }
    }
    plhs[0] = A;
    return;
  }