//
//  Network Definitions.hpp
//  Cell Sim
//
//  Created by Desire on 2026-08-19.
//

#ifndef Network_Definitions_hpp
#define Network_Definitions_hpp

#ifdef __cplusplus

#include <stdio.h>
#include <vector>
#include <cmath>

struct Neuron {
    double wieght; // legacy weight property name preserved for compatibility
    double bias;
    std::vector<double> weights; // multi-input weights
    
    Neuron() : wieght(1.0), bias(0.0) {}
    Neuron(double w, double b) : wieght(w), bias(b) {}
    Neuron(const std::vector<double>& w, double b) : wieght(w.empty() ? 0.0 : w[0]), bias(b), weights(w) {}
    
    double activate(const std::vector<double>& inputs) const;
};

struct NetworkLayer {
    std::vector<Neuron> neurons;
    
    void addNeuron(const Neuron& neuron);
};

class NeuralNetwork {
public:
    NeuralNetwork();
    
    void addInputNeuron(const Neuron& neuron);
    void addLayer(const NetworkLayer& layer);
    void addOutputNeuron(const Neuron& neuron);
    NetworkLayer getLastHiddenLayer();
    void deleteLastHiddenLayer();
    
    std::vector<Neuron> inputNeurons;
    std::vector<NetworkLayer> hiddenNeurons;
    std::vector<Neuron> outputNeurons;
    
    int getNumOfInputNeurons();
    int getNumOfOutputNeurons();
    
    std::vector<double> run(const std::vector<double>& inputs);
    
    // C++ / Swift bridge helper using pointer & count
    std::vector<double> runWithValues(const double* values, size_t count);
    
    static NeuralNetwork createRandomNetwork(int numInputs, int numHidden, int numOutputs);
};

#endif // __cplusplus

#endif /* Network_Definitions_hpp */
