//
//  AppDelegate.swift
//  HealthKit-MVVM
//
//  Created by Frank Martin on 4/11/19.
//  Copyright © 2019 Frank Martin. All rights reserved.
//

import UIKit
import HealthKit

struct Dependencies {
    let healthKitService = HealthKitService()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let healthKitService = HealthKitService()
    
    let window = UIWindow(frame: UIScreen.main.bounds)
    let coordinator = Coordinator(with: Dependencies(), and: .showList)
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window.rootViewController = coordinator.navigationController
        window.makeKeyAndVisible()
        
//        let sample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .heartRate)!, quantity: HKQuantity(unit: HKUnit.count().unitDivided(by: .minute()), doubleValue: 65.3), start: Date(), end: Date(timeInterval: 60, since: Date()), device: HKDevice.local(), metadata: nil)
//        healthKitService.requestAuthorization { (success) in
//            if success {
//                self.healthKitService.healthStore.save(sample, withCompletion: { (success, error) in
//                    self.healthKitService.fetchHeartRates(completion: { (heartRates) in
//                    })
//                })
//            }
//        }

//        print(sample)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

