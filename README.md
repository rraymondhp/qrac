# Quantum Random Access Coding (QRAC)

By Rudy Raymond

## What is Quantum Random Access Coding?

Quantum Random Access Coding (QRAC) is an encoding protocol to encode n bits of information into m qubits so that any 1 out of n bits can be extracted with non-trivial success probabilities when n > m. For convenience, a (n, m, p)-QRAC denotes such encoding scheme where p > 1/2 denotes the success probability (which can be defined as the worst-case success probability, or the average-case success probability). 

## Resources on QRAC

There are tutorials of QRACs on qiskit-tutorial as [here](https://nbviewer.jupyter.org/github/Qiskit/qiskit-tutorial/blob/master/appendix/more_qis/single-qubit_quantum_random_access_coding.ipynb) and [here](https://nbviewer.jupyter.org/github/Qiskit/qiskit-tutorial/blob/master/appendix/more_qis/two-qubit_state_quantum_random_access_coding.ipynb). QRACs are related to PR boxes and are known useful to generate random numbers with quantum devices. 

## This repository

This repository is a companion to [Constructions of Quantum Random Access Codes](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&cad=rja&uact=8&ved=2ahUKEwj_5dX089fdAhXFxrwKHUKvDZoQFjACegQIBxAC&url=http%3A%2F%2Fwww.ngc.is.ritsumei.ac.jp%2F~ger%2Fstatic%2FAQIS18%2FOnlineBooklet%2F122.pdf&usg=AOvVaw193PvEbagFZsAl7bYhboiI) presented at [AQIS 2018](http://aqis-conf.org/2018/) in Nagoya, Japan. 

This repository is aimed to gather information of QRACs, and will be updated accordingly. 

## Prerequisites

You need to install `qiskit` and `qiskit-tutorial` repositories to run the codes.
Please follow the installation steps [here](https://github.com/QISKit/qiskit-tutorial/blob/master/INSTALL.md).

## List of files

Below are two-qubit QRACs that are known to be better than those found in [Improved Classical and Quantum Random Access Codes](https://arxiv.org/abs/1607.02667). The results are summarized as follows:

| n | 3 | 5 | 7 | 8 | 9 |
|---|---|---|---|---|---|
|p [here](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&cad=rja&uact=8&ved=2ahUKEwj_5dX089fdAhXFxrwKHUKvDZoQFjACegQIBxAC&url=http%3A%2F%2Fwww.ngc.is.ritsumei.ac.jp%2F~ger%2Fstatic%2FAQIS18%2FOnlineBooklet%2F122.pdf&usg=AOvVaw193PvEbagFZsAl7bYhboiI)|0.908 | 0.811| 0.702| 0.690| 0.671|
|p [prev](https://arxiv.org/abs/1607.02667)|0.853|0.788|0.684|0.652|0.621|


Here is the list the two-qubit QRACs:
1. The [(3,2)-QRAC](32QRAC.ipynb): encoding 3 bits into 2 qubits. The classical RAC has success probability 2/3.
2. The [(5,2)-QRAC](QRAC_for_5_bits_with_2_qubits.ipynb): encoding 5 bits into 2 qubits. No classical RACs can perform this with 2 bits.
3. The [(7,2)-QRAC](QRAC_for_7_bits_with_2_qubits.ipynb): encoding 7 bits into 2 qubits. No classical RACs can perform this with 2 bits.
4. The [(8,2)-QRAC](QRAC_for_8_bits_with_2_qubits.ipynb): encoding 8 bits into 2 qubits. No classical RACs can perform this with 2 bits.
5. The [(9,2)-QRAC](QRAC_for_9_bits_with_2_qubits.ipynb): encoding 9 bits into 2 qubits. No classical RACs can perform this with 2 bits.

### Acknowledgement

Special thanks to Keita Takeuchi of Univ. of Tokyo for preparing the states and measurements of the (5,2)-QRACs.
