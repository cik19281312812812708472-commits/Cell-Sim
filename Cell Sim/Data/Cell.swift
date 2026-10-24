//
//  Cell.swift
//  Cell Sim
//
//  Created by Desire on 2026-08-19.
//

import SpriteKit
import Foundation

public typealias DNA = String

extension NeuralNetwork {
    /// Helper extension to run feedforward evaluation directly with Swift arrays
    mutating func run(inputs: [Double]) -> [Double] {
        var mutableInputs = inputs
        let cOutputs = self.runWithValues(&mutableInputs, mutableInputs.count)
        var result: [Double] = []
        for i in 0..<cOutputs.size() {
            result.append(cOutputs[i])
        }
        return result
    }
}

class Cell: SKShapeNode {
    
    var color: SKColor
    var radius: CGFloat
    var intelligent: Bool
    var neuralNetwork: NeuralNetwork?
    
    var movingVector: CGVector = CGVector(dx: 0, dy: 0)
    var energy = 1000.0
    var maxSpeed = 10.0
    var minEnergy = 10.0
    var dna: String
    
    /// The stuff the cell does each update frame
    func exist(cells: [Cell] = [], sceneSize: CGSize = CGSize(width: 1000, height: 1000)) {
        energy += 1
        move(cells: cells, sceneSize: sceneSize)
    }
    
    func move(cells: [Cell] = [], sceneSize: CGSize = CGSize(width: 1000, height: 1000)) {
        if intelligent {
            moveIntelligently(cells: cells, sceneSize: sceneSize)
        } else {
            if energy >= minEnergy && energy > 0 {
                if Bool.random() {
                    let increase: (x: CGFloat, y: CGFloat) = (x: CGFloat.random(in: -10...10), y: CGFloat.random(in: -10...10))
                    movingVector.dx += increase.x
                    movingVector.dy += increase.y
                    
                    energy -= sqrt(Double(pow(increase.x, 2)) + Double(pow(increase.y, 2))) / 1000
                }
            }
            
            movingVector.dx *= 0.98
            movingVector.dy *= 0.98
            
            self.position.x += movingVector.dx
            self.position.y += movingVector.dy
        }
    }
    
    private func moveIntelligently(cells: [Cell], sceneSize: CGSize) {
        // Initialize neural network if missing
        if self.neuralNetwork == nil {
            self.neuralNetwork = NeuralNetwork.createRandomNetwork(7, 8, 2)
        }
        
        guard energy >= minEnergy && energy > 0, var net = self.neuralNetwork else {
            // Low energy: apply friction and drift
            movingVector.dx *= 0.98
            movingVector.dy *= 0.98
            self.position.x += movingVector.dx
            self.position.y += movingVector.dy
            return
        }
        
        // 1. Gather sensory inputs
        let halfWidth = sceneSize.width > 0 ? sceneSize.width / 2.0 : 500.0
        let halfHeight = sceneSize.height > 0 ? sceneSize.height / 2.0 : 500.0
        let normX = Double((self.position.x - halfWidth) / halfWidth)
        let normY = Double((self.position.y - halfHeight) / halfHeight)
        
        let normVelX = Double(movingVector.dx / maxSpeed)
        let normVelY = Double(movingVector.dy / maxSpeed)
        
        let normEnergy = min(max(energy / 1000.0, 0.0), 1.0)
        
        var dxToNearest: Double = 0.0
        var dyToNearest: Double = 0.0
        var minDistanceSq: CGFloat = .greatestFiniteMagnitude
        
        for otherCell in cells {
            if otherCell === self { continue }
            let dx = otherCell.position.x - self.position.x
            let dy = otherCell.position.y - self.position.y
            let distSq = dx * dx + dy * dy
            if distSq < minDistanceSq {
                minDistanceSq = distSq
                dxToNearest = Double(dx / halfWidth)
                dyToNearest = Double(dy / halfHeight)
            }
        }
        
        // 2. Feed inputs into the neural network
        let inputsArray: [Double] = [normX, normY, normVelX, normVelY, normEnergy, dxToNearest, dyToNearest]
        let outputs = net.run(inputs: inputsArray)
        
        var outX: Double = 0.0
        var outY: Double = 0.0
        if outputs.count >= 2 {
            outX = outputs[0]
            outY = outputs[1]
        } else if outputs.count == 1 {
            outX = outputs[0]
        }
        
        // 3. Convert network output to movement acceleration
        let forceMultiplier: CGFloat = 1.5
        let forceX = CGFloat(outX) * forceMultiplier
        let forceY = CGFloat(outY) * forceMultiplier
        
        movingVector.dx += forceX
        movingVector.dy += forceY
        
        // Clamp maximum speed
        let speed = sqrt(movingVector.dx * movingVector.dx + movingVector.dy * movingVector.dy)
        if speed > maxSpeed {
            movingVector.dx = (movingVector.dx / speed) * maxSpeed
            movingVector.dy = (movingVector.dy / speed) * maxSpeed
        }
        
        // Deduct energy based on thrust applied
        let appliedThrust = sqrt(Double(forceX * forceX + forceY * forceY))
        energy -= appliedThrust / 100.0
        
        // Apply friction/damping
        movingVector.dx *= 0.98
        movingVector.dy *= 0.98
        
        // Update position
        self.position.x += movingVector.dx
        self.position.y += movingVector.dy
    }
    
    static func getRandomDNA() -> DNA {
        return ""
    }
    
    init(color: SKColor, radius: CGFloat, intelligent: Bool = false, neuralNetwork: NeuralNetwork? = nil) {
        self.color = color
        self.radius = radius
        self.intelligent = intelligent
        self.neuralNetwork = neuralNetwork ?? (intelligent ? NeuralNetwork.createRandomNetwork(7, 8, 2) : nil)
        
        self.dna = Cell.getRandomDNA()
        
        super.init()
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        self.fillColor = color
    }
    
    init(dna: DNA) {
        self.color = .red
        self.radius = 10
        self.intelligent = false
        self.neuralNetwork = nil
        self.dna = dna
        
        let tokens = dna.split(separator: " ")
        var colorSet: Bool = false
        var radiusSet: Bool = false
        
        func convertDNAToDouble(_ dnaToken: DNA, caseA: (Double) -> (Double), caseC: (Double) -> (Double), caseT: (Double) -> (Double), caseG: (Double) -> (Double)) -> Double {
            var value = 0.0
            let letters = Array(dnaToken)
            for letter in letters {
                switch letter {
                case "A": value = caseA(value)
                case "T": value = caseT(value)
                case "C": value = caseC(value)
                case "G": value = caseG(value)
                default: break
                }
            }
            return value
        }
        
        var idx = 0
        while idx < tokens.count {
            var token = String(tokens[idx])
            
            switch token {
            case "ACCGA": token = "COLOR:"
            case "ACCDACAT":
                token = "INTELLIGENT:"
                intelligent = true
            case "ACCCT": token = "RADIUS:"
            case "ACCTGTAACTTGATCGATCGATCGGATAG": token = "NEURALNETWORKLAYER:"
            default: break
            }
            
            switch token {
            case "COLOR:":
                var red = 0.0, green = 0.0, blue = 0.0, alphaPercent = 1.0
                if idx + 4 < tokens.count {
                    for offset in 1...4 {
                        let letterValue = tokens[idx + offset]
                        var value = 0.0
                        for letter in letterValue {
                            switch letter {
                            case "A": value += 50
                            case "T": value -= 20
                            case "C": value += 0.5
                            case "G": value += 1
                            default: break
                            }
                        }
                        if value < 0 { value = -value }
                        if offset < 4 {
                            while value > 255 { value -= 255 }
                        }
                        
                        if offset == 1 { red = value }
                        else if offset == 2 { green = value }
                        else if offset == 3 { blue = value }
                        else { alphaPercent = value / 100.0 }
                    }
                    idx += 4
                }
                
                if !colorSet {
                    self.color = SKColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alphaPercent)
                    colorSet = true
                }
                
            case "RADIUS:":
                if idx + 1 < tokens.count {
                    var value: CGFloat = 0.0
                    let code = tokens[idx + 1]
                    for letter in code {
                        switch letter {
                        case "A": value += 5
                        case "T": value -= 2
                        case "C": value += 0.5
                        case "G": value += 1
                        default: break
                        }
                    }
                    if radiusSet {
                        self.radius = (self.radius + value) / 2
                    } else {
                        self.radius = value
                        radiusSet = true
                    }
                    idx += 1
                }
                
            case "NEURALNETWORKLAYER:":
                var neurons: [Neuron] = []
                var step = 1
                while idx + step + 1 < tokens.count {
                    let weightStr = tokens[idx + step]
                    let biasStr = tokens[idx + step + 1]
                    
                    if weightStr.hasPrefix("ACC") || biasStr.hasPrefix("ACC") {
                        break
                    }
                    
                    let weight = convertDNAToDouble(String(weightStr), caseA: { $0 * 0.1 }, caseC: { $0 + 1 }, caseT: { $0 - 1 }, caseG: { $0 + 5 })
                    let bias = convertDNAToDouble(String(biasStr), caseA: { $0 * 0.1 }, caseC: { $0 + 1 }, caseT: { $0 - 1 }, caseG: { $0 + 5 })
                    neurons.append(Neuron(weight, bias))
                    step += 2
                }
                idx += (step - 1)
                
                if self.neuralNetwork == nil {
                    self.neuralNetwork = NeuralNetwork()
                    for neuron in neurons {
                        self.neuralNetwork!.addOutputNeuron(neuron)
                    }
                } else {
                    var layer = NetworkLayer()
                    for neuron in neurons {
                        layer.addNeuron(neuron)
                    }
                    self.neuralNetwork!.addLayer(layer)
                }
                
            default: break
            }
            
            idx += 1
        }
        
        if intelligent && self.neuralNetwork == nil {
            self.neuralNetwork = NeuralNetwork.createRandomNetwork(7, 8, 2)
        }
        
        super.init()
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        self.fillColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
