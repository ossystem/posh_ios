//
//  BLEService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 28/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxBluetoothKit
import RxSwift
import CoreBluetooth

enum DeviceCharacteristic: String, CharacteristicIdentifier {
    case manufacturerName = "2A29"

    var uuid: CBUUID {
        return CBUUID(string: self.rawValue)
    }
    //Service to which characteristic belongs
    var service: ServiceIdentifier {
        switch self {
        case .manufacturerName:
            return DeviceService.deviceInformation
        }
    }
}
enum DeviceService: String, ServiceIdentifier {
    case deviceInformation = "180A"

    var uuid: CBUUID {
        return CBUUID(string: self.rawValue)
    }
}

class BLEService {

    static var shared = BLEService()

    let manager = BluetoothManager(queue: .main)

    func discover() {
        _ = manager.rx_state
            .filter { $0 == .poweredOn }
            .take(1)
            .flatMap { _ in
               return self.manager
                    .scanForPeripherals(withServices: nil)
                    .flatMap{ $0.peripheral.connect() }
                    .flatMap{ per in
                        return per
                            .discoverServices(nil)
                            .withLatestFrom(Observable.just(per)) { return ($0.0, $0.1) }
                    }
                .do(onNext: { (servs, per) in
                    print(per.name, servs.map{ $0.uuid.uuidString }.reduce("") { "\($0)\n    \($1)" })
                })
            }
            .subscribe()
//            .map { $0.peripheral.connect()
//            .do (onNext: { print($0.name) })
//            .flatMap { $0.discoverServices(nil) }
//            .flatMap { Observable.from($0) }
//            .subscribe( onNext: { serv in
//                print("    \(serv.uuid.uuidString)")
//            })
//        }
//        .subscribe
        
        
    }
}
