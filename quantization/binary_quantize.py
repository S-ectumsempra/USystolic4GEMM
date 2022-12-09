import numpy as np
from unary_gemm import unary_gemm

def binary_quantize(x:np.ndarray, bins:np.ndarray):
    inds = np.digitize(x, bins)
    xQuant = bins[inds]
    return xQuant

if __name__=='__main__':
    n_input = 10
    m_input = 5
    k_weight = 6
    binary_bitwidth = 3
    unary_bitwidth = 2**(binary_bitwidth-1)
    bins = np.linspace(0,1,1+2**binary_bitwidth)

    inputFeature = 2*np.random.rand(n_input,m_input)-1
    weight = 2*np.random.rand(m_input, k_weight)-1

    inputFeatureQuant = binary_quantize(inputFeature, bins)
    weightQuant = binary_quantize(weight, bins)

    result_true = inputFeature @ weight
    result_binary = inputFeatureQuant @ weightQuant
    result_unary = unary_gemm(inputFeatureQuant, weightQuant, unary_bitwidth)
    print('Ground truth norm:%.3f, Binary error norm:%.3f, Unary error norm:%.3f'% 
            (   np.linalg.norm(result_true),
                np.linalg.norm(result_true-result_binary),
                np.linalg.norm(result_true-result_unary)))
    
