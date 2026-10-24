//
//  Network Definitions.cpp
//  Cell Sim
//
//  Created by Desire on 2026-08-19.
//

#include "Network Definitions.hpp"
#include <vector>
#include <cmath>
#include <random>

NeuralNetwork::NeuralNetwork() {}

double Neuron::activate(const std::vector<double>& inputs) const {
    double sum = bias;
    if (!weights.empty()) {
        for (size_t i = 0; i < inputs.size(); ++i) {
            double w = (i < weights.size()) ? weights[i] : wieght;
            sum += inputs[i] * w;
        }
    } else {
        for (size_t i = 0; i < inputs.size(); ++i) {
            sum += inputs[i] * wieght;
        }
    }
    return std::tanh(sum);
}

void NeuralNetwork::addInputNeuron(const Neuron& neuron) {
    inputNeurons.push_back(neuron);
}

void NeuralNetwork::addOutputNeuron(const Neuron& neuron) {
    outputNeurons.push_back(neuron);
}

void NeuralNetwork::addLayer(const NetworkLayer& layer) {
    hiddenNeurons.push_back(layer);
}

void NetworkLayer::addNeuron(const Neuron& neuron) {
    neurons.push_back(neuron);
}

NetworkLayer NeuralNetwork::getLastHiddenLayer() {
    if (!hiddenNeurons.empty()) {
        return hiddenNeurons.back();
    }
    return NetworkLayer();
}

void NeuralNetwork::deleteLastHiddenLayer() {
    if (!hiddenNeurons.empty()) {
        hiddenNeurons.pop_back();
    }
}

int NeuralNetwork::getNumOfInputNeurons() {
    return static_cast<int>(inputNeurons.size());
}

int NeuralNetwork::getNumOfOutputNeurons() {
    return static_cast<int>(outputNeurons.size());
}

std::vector<double> NeuralNetwork::run(const std::vector<double>& inputs) {
    if (outputNeurons.empty()) {
        return {0.0, 0.0};
    }
    
    std::vector<double> currentInputs = inputs;
    
    // Process input layer if present
    if (!inputNeurons.empty()) {
        std::vector<double> nextInputs;
        for (const auto& neuron : inputNeurons) {
            nextInputs.push_back(neuron.activate(currentInputs));
        }
        currentInputs = nextInputs;
    }
    
    // Process hidden layers
    for (const auto& layer : hiddenNeurons) {
        if (layer.neurons.empty()) continue;
        std::vector<double> nextInputs;
        for (const auto& neuron : layer.neurons) {
            nextInputs.push_back(neuron.activate(currentInputs));
        }
        currentInputs = nextInputs;
    }
    
    // Process output layer
    std::vector<double> outputs;
    for (const auto& neuron : outputNeurons) {
        outputs.push_back(neuron.activate(currentInputs));
    }
    
    return outputs;
}

std::vector<double> NeuralNetwork::runWithValues(const double* values, size_t count) {
    std::vector<double> inputs(values, values + count);
    return run(inputs);
}

NeuralNetwork NeuralNetwork::createRandomNetwork(int numInputs, int numHidden, int numOutputs) {
    NeuralNetwork net;
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<double> dist(-1.0, 1.0);
    
    // Hidden layer
    NetworkLayer hiddenLayer;
    for (int h = 0; h < numHidden; ++h) {
        std::vector<double> weights(numInputs);
        for (int i = 0; i < numInputs; ++i) {
            weights[i] = dist(gen);
        }
        double bias = dist(gen);
        hiddenLayer.addNeuron(Neuron(weights, bias));
    }
    net.addLayer(hiddenLayer);
    
    // Output layer
    for (int o = 0; o < numOutputs; ++o) {
        std::vector<double> weights(numHidden > 0 ? numHidden : numInputs);
        for (size_t w = 0; w < weights.size(); ++w) {
            weights[w] = dist(gen);
        }
        double bias = dist(gen);
        net.addOutputNeuron(Neuron(weights, bias));
    }
    
    return net;
}
