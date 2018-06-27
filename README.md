# Quantum Random Access Coding (QRAC)

By Rudy Raymond

## Prerequisites

You need to install `qiskit` and `qiskit-tutorial` repositories to run the codes.
Please follow the installation steps [here](https://github.com/QISKit/qiskit-tutorial/blob/master/INSTALL.md).

## List of files

This is the repository for documenting two-qubit QRACs. The definition of QRACs and
some examples of QRACs can be found [here](https://nbviewer.jupyter.org/github/QISKit/qiskit-tutorial/blob/master/appendix/more_qis/single-qubit_quantum_random_access_coding.ipynb) and [here](https://nbviewer.jupyter.org/github/QISKit/qiskit-tutorial/blob/master/appendix/more_qis/two-qubit_state_quantum_random_access_coding.ipynb).

Here is the list the two-qubit QRACs:
1. The [(3,2)-QRAC](32QRAC.ipynb): encoding 3 bits into 2 qubits. The classical RAC has success probability 2/3.
2. The [(5,2)-QRAC](QRAC_for_5_bits_with_2_qubits.ipynb): encoding 5 bits into 2 qubits. No classical RACs can perform this with 2 bits.
3. The [(7,2)-QRAC](QRAC_for_7_bits_with_2_qubits.ipynb): encoding 7 bits into 2 qubits. No classical RACs can perform this with 2 bits.
4. The [(8,2)-QRAC](QRAC_for_8_bits_with_2_qubits.ipynb): encoding 8 bits into 2 qubits. No classical RACs can perform this with 2 bits.
5. The [(9,2)-QRAC](QRAC_for_9_bits_with_2_qubits.ipynb): encoding 9 bits into 2 qubits. No classical RACs can perform this with 2 bits.

### Acknowledgement

Special thanks to Keita Takeuchi of Univ. of Tokyo for preparing the states and measurements of the (5,2)-QRACs.
