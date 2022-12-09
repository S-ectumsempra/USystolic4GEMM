import numpy as np
from binary_quantize import binary_quantize
from unary_gemm import unary_gemm
import matplotlib.pyplot as plt

if __name__=='__main__':
    n_input = 3
    m_input = 3
    k_weight = 6
    fig = plt.figure(figsize=(5.5,4.5))
    colorList=['brown','blue','red']
    np.random.seed(0)
    plt.plot(range(2,17),np.zeros((15,1)),color='black')
    for i in range(3):
        binaryErrorList = []
        unaryErrorList = []
        if i ==0:
            n_input = 3
            m_input = 3
            k_weight = 3
        elif i ==1:
            n_input = 5
            m_input = 5
            k_weight = 5
        elif i ==2:
            n_input = 10
            m_input = 10
            k_weight = 10
        inputFeature = 2*np.random.rand(n_input,m_input)-1
        weight = 2*np.random.rand(m_input, k_weight)-1
        result_true = inputFeature @ weight
            
        for effective_binary_bitwidth in range(2,17):
            unary_bitwidth = 2**(effective_binary_bitwidth)
            bins = np.linspace(-1,1,1+2**effective_binary_bitwidth)


            inputFeatureQuant = binary_quantize(inputFeature, bins)
            weightQuant = binary_quantize(weight, bins)

            result_binary = inputFeatureQuant @ weightQuant
            result_unary = unary_gemm(inputFeatureQuant, weightQuant, unary_bitwidth)
            binaryError = np.linalg.norm(result_true-result_binary,ord=2)/(n_input*m_input)
            unaryError = np.linalg.norm(result_true-result_unary, ord=2)/(n_input*m_input)
            binaryErrorList.append(binaryError)
            unaryErrorList.append(unaryError)
            print('binary_bitwidth:%d, Ground truth norm:%.5f, Binary error norm:%.5f, Unary error norm:%.5f'% 
                    (   effective_binary_bitwidth,
                        np.linalg.norm(result_true),
                        binaryError,
                        unaryError))
        plt.plot(range(2,17),binaryErrorList,'--',color=colorList[i])
        plt.plot(range(2,17),unaryErrorList,color=colorList[i])
    plt.xlabel('Effective Binary Bitwidth')
    plt.ylabel('Normalized $L_2$ Error')
    plt.legend(['Ground Truth: Float',
                '3*3 Binary Error','3*3 Unary Error',
                '5*5 Binary Error','5*5 Unary Error',
                '10*10 Binary Error','10*10 Unary Error'])
    # plt.savefig(f'UnaryError{n_input}_{m_input}.pdf')
    plt.savefig(f'UnaryErrorAll.pdf')
