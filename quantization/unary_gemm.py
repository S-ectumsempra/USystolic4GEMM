import numpy as np

def unary_gemm(inputFeature, weight, unary_bitwidth):
    n_input = inputFeature.shape[0]
    k_weight = weight.shape[1]
    result = np.zeros((n_input, k_weight))
    isign = inputFeature >= 0
    isign = 2*isign-1
    wsign = weight >=0
    wsign = 2*wsign-1
    iabs = np.abs(inputFeature)
    wabs = np.abs(weight)
    for i in range(unary_bitwidth):
        iRng = np.random.rand(*iabs.shape) 
        iUnary = iabs > iRng
        wRng = np.random.rand(*wabs.shape)
        wUnary = wabs > wRng
        result += (isign*iUnary) @ (wsign*wUnary)
    return result/unary_bitwidth


if __name__=='__main__':
    n_input = 10
    m_input = 5
    k_weight = 6
    unary_bitwidth = 2 ** 16

    inputFeature = 2*np.random.rand(n_input,m_input)-1
    weight = 2*np.random.rand(m_input, k_weight)-1

    result_true = inputFeature @ weight
    result_gemm = unary_gemm(inputFeature, weight, unary_bitwidth)
    print('Ground Truth Norm:%.3f, Error Norm:%.3f'% (np.linalg.norm(result_true),np.linalg.norm(result_true-result_gemm)))
