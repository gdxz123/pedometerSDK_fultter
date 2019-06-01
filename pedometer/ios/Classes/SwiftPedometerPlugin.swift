import Flutter
import UIKit
import HealthKit

public class SwiftPedometerPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "gd_flutter_sdk_pedometer", binaryMessenger: registrar.messenger())
        let instance = SwiftPedometerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
        } else if call.method == "getTodayStepCount" {
            self.getHealthKitPermission { (isAcceptAuth) in
                if isAcceptAuth {
                    self.getTodayStepCount { (stepCount) in
                        result("\(stepCount)")
                    }
                } else {
                    // no permition
                    result("-1")
                }
            }
        } else {
            result("")
        }
    }
    
    /// Getter & Setter
    lazy var healthStore: HKHealthStore = {
        let healthStore: HKHealthStore = HKHealthStore()
        return healthStore
    }()
    
    private func getHealthKitPermission(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
            
        let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

        self.healthStore.requestAuthorization(toShare: [], read: [stepsCount]) { (success, error) in
            if success {
                debugPrint("Permission accept.")
                completion(true)
            } else {
                debugPrint("Permission denied.")
                completion(false)
            }
        }
    }
    
    private func getTodayStepCount(completion: @escaping (Double) -> Void) {
        guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        let now: Date = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        healthStore.execute(query)
    }
}
