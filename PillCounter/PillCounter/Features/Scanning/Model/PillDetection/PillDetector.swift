//
//  PillDetector.swift
//  PillCounter
//
//  Created by HC on 24/11/25.
//

import CoreML
import UIKit
import Vision

final class PillDetector {

    // singleton
    static let shared = PillDetector()

    // model
    private(set) var model: best?

    private init() {
        print("🔄 PillDetector.init called")
        loadModel()
    }

    // load model
    private func loadModel() {

        do {

            let config = MLModelConfiguration()
            
            config.computeUnits = .cpuAndGPU
            
            let mlModel = try best(configuration: config)
            self.model = mlModel
            print("✅ MODEL LOADED SUCCESSFULLY")

        } catch let error {
            print("❌ FALIED TO LOAD MODEL: \(error)")
        }
    }
}
