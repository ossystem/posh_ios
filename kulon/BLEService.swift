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
    
    case control = "6e400004-b5a3-f393-e0a9-e50e24dcca9e"
    case fileUpload = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    case notifications = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

    var uuid: CBUUID {
        return CBUUID(string: self.rawValue.uppercased())
    }
    //Service to which characteristic belongs
    var service: ServiceIdentifier {
        switch self {
        case .manufacturerName:
            return DeviceService.deviceInformation
        case .control, .fileUpload, .notifications:
            return DeviceService.imageService
        }
    }
}

enum DeviceService: String, ServiceIdentifier {
    
    case deviceInformation = "180A"
    case imageService = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    case other = "00001530-1212-efde-1523-785feabcd123"
    
    
    var uuid: CBUUID {
        return CBUUID(string: self.rawValue.uppercased())
    }
}

class KulonService {
    
    let disposeBag = DisposeBag()

    var service: Service
    var upload: Characteristic
    var control: Characteristic
    var notifications: Characteristic

    var notificationValueUpldated: Observable<Characteristic> {
        return notifications.setNotificationAndMonitorUpdates().debug()
    }
    
    init(_ characteristics: [Characteristic]) {
        service = characteristics[0].service
        control = characteristics.first(where: { $0.uuid == DeviceCharacteristic.control.uuid })!
        upload = characteristics.first(where: { $0.uuid == DeviceCharacteristic.fileUpload.uuid })!
        notifications = characteristics.first(where: { $0.uuid == DeviceCharacteristic.notifications.uuid })!
    }
    
    deinit {
        service.peripheral.cancelConnection()
        .subscribe().disposed(by: disposeBag)
        print("service deinited")
    }
}

enum FileOperationResult {
    case opened
    case error
    case undefined
    
    init(_ data: Data?) {
        guard let data = data
            else {
                self = .undefined
                return
            }
        switch data[0] {
        case 101: // 'e'
            self = .error
        case 111: // 'o'
            self = .opened
        default:
            self = .undefined
        }
    }
}


class DeviceError : Error {
    
}

class BLEService {

    static var shared = BLEService()
    
    let disposeBag = DisposeBag()
    let manager = BluetoothManager(queue: .main)
    var imageServiceFound: PublishSubject<Service> = PublishSubject<Service>()
    var controlCharacteristicDiscovered:  ReplaySubject<Characteristic> = ReplaySubject<Characteristic>.create(bufferSize: 1)
    var uploadCharacteriscticDiscovered: ReplaySubject<Characteristic> = ReplaySubject<Characteristic>.create(bufferSize: 1)
    
    var notificationsCharacteristicChanged: PublishSubject<Characteristic> = PublishSubject<Characteristic>()
    
    init() {
       // discover()
    }

    private func discover() -> Observable<KulonService>{
        return manager.rx_state
            .filter { $0 == .poweredOn }
            .flatMap { _ -> Observable<Peripheral> in
               return self.manager
                    .scanForPeripherals(withServices: nil)
                    .flatMap{ per -> Observable<Peripheral> in
                        //filter on uuid
                        return per.peripheral.connect()
                        
                }
            }
            .flatMap {
                $0.discoverServices(nil)
            }
            .filter { services in
                for service in services {
                    if service.uuid == DeviceService.imageService.uuid {
                        return true
                    }
                }
                //TODO: cancel connections
                return false
            }
            .take(1)
            .flatMap { service in
                service.first(where: { $0.uuid == DeviceService.imageService.uuid })!
                .discoverCharacteristics(nil)
            }
            .map {
                KulonService($0)
            }
            .shareReplayLatestWhileConnected()
            
            /*.subscribe(onNext: { [unowned self] in
                self.imageServiceFound.onNext($0)
            }).disposed(by: disposeBag)
        
        imageServiceFound
            .flatMap {
            $0.discoverCharacteristics(nil)
            }
            .filter { chars in
            for char in chars {
                    if char.uuid == DeviceCharacteristic.control.uuid {
                       return true
                    }
                }
                return false
            }
            .take(1)
            
            .do(onNext: { [unowned self] chars in
                self.controlCharacteristicDiscovered.onNext(chars.first(where: { $0.uuid == DeviceCharacteristic.control.uuid })!)
                self.uploadCharacteriscticDiscovered.onNext(chars.first(where: { $0.uuid == DeviceCharacteristic.fileUpload.uuid })!)
            })
            .flatMap { chars in
                chars.first(where: { $0.uuid == DeviceCharacteristic.notifications.uuid })!
                    .setNotificationAndMonitorUpdates()
            }
            .bindTo(self.notificationsCharacteristicChanged)
            .disposed(by: self.disposeBag)
 */
    }
    
    private func sendCommand(_ command: BLEControlCommand, to service: KulonService? = nil) -> Observable<(FileOperationResult, KulonService)> {
        if service != nil && service!.service.peripheral.isConnected {
            return service!.notificationValueUpldated
                .withLatestFrom(
                    service!.control.writeValue(command.data, type: .withoutResponse)
                    )
                {
                    notificaction, control in
                    return (FileOperationResult(notificaction.value), service!)
            }

        }
        return discover()
            .flatMap { service in
                service.notificationValueUpldated
                    .withLatestFrom(
                        service.control.writeValue(command.data, type: .withoutResponse)
                    )
                    {
                        notificaction, control in
                        return (FileOperationResult(notificaction.value), service)
                    }
        }
        
                /*service.control.writeValue(command.data, type: .withoutResponse)
                    
                    .withLatestFrom(service.notifications)
                    .map {
                        (FileOperationResult($0.value), service)
                    }
                    .retry(3)
        }
        */
        
       /* return controlCharacteristicDiscovered
            .flatMap {
                $0.writeValue(command.data, type: .withoutResponse)
                .delay(0.5, scheduler: MainScheduler.instance)
            }
            .retryWhen { [unowned self] in
                $0.do(onNext: { _ in
                    self.discover()
                })
                .map { _ in }
            }
            .withLatestFrom(notificationsCharacteristicChanged)
 */
    }
    
    func set(_ poshik: UploadablePoshik) -> Observable<Void> {
        return  sendCommand(.openImage(poshik.name))
            .flatMap { [unowned self] result, service -> Observable<Void> in
                switch result {
                case .opened:
                    return Observable.just()
                case .error:
                    return self.upload(poshik, with: service)
                case .undefined:
                    return Observable.error(DeviceError())
                }
            }
    }
    
    func upload(_ poshik: UploadablePoshik, with service: KulonService) -> Observable<Void> {
        
        let file = poshik.imageForUpload
        return sendCommand(.createImage(poshik.name), to: service)
            .flatMap { result, service -> Observable<Characteristic> in
                    file.asObservable().flatMap { file -> Observable<NSData> in
                        let chunkedFile = (file.data as NSData).chunked(of: 20)
                        print(chunkedFile.count)
                        return Observable.from(chunkedFile)
                    }
                    .flatMap {
                        return service.upload.writeValue(Data(referencing: $0) , type: .withResponse)
                    }
                    .takeLast(1)
            }
            .flatMap { [unowned self] _ in
                self.sendCommand(.closeWriting, to: service)
            }
            .map { _ in }
    }
    
}
