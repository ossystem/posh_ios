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
        return notifications.setNotificationAndMonitorUpdates()
            .catchError {_ in Observable.empty() }
            .do(onNext: {
                print("BLEService: recieved \(String(describing: FileOperationResult($0.value)))")
            })
    }
    
    init(_ characteristics: [Characteristic]) throws {
        service = characteristics[0].service
        guard
            let control = characteristics.first(where: { $0.uuid == DeviceCharacteristic.control.uuid }),
            let upload = characteristics.first(where: { $0.uuid == DeviceCharacteristic.fileUpload.uuid }),
            let notifications = characteristics.first(where: { $0.uuid == DeviceCharacteristic.notifications.uuid })
            else { throw RecognizingDeviceError() }
        
        self.control = control
        self.upload = upload
        self.notifications = notifications
        
        print(service.peripheral.identifier.uuidString)
    }
    
    deinit {
        service.peripheral.cancelConnection()
            .subscribe( {_ in 
                print("Connection canceled")
                }).disposed(by: disposeBag)
        print("service deinited")
    }
}

class RecognizingDeviceError: Error {
    
}

enum FileOperationResult {
    case opened
    case error(FileOperationError)
    case undefined
    
    enum FileOperationError {
        case fileNotExist
        case decodingError
        case resolutionError
        case undefined
        init(_ code: Int) {
            switch code {
            case -1:
                self = .fileNotExist
            case -2:
                self = .decodingError
            case -3:
                self = .resolutionError
            default:
                self = .undefined
            }
        }
        
    }
    
    init(_ data: Data?) {
        guard let data = data
            else {
                self = .undefined
                return
            }
        switch data[0] {
        case 101: // 'e'
            self = .error(FileOperationError(Int(data[1]) - 256))
        case 111: // 'o'
            self = .opened
        default:
            self = .undefined
        }
    }
}


class DeviceError : LocalizedError {
    var localizedDescription: String {
        return "Device error"
    }
    var errorDescription: String? {
        return localizedDescription
    }
}

class ImageErorr : LocalizedError {
    var localizedDescription: String {
        return "Something wrong with the image"
    }
    var errorDescription: String? {
        return localizedDescription
    }
}

class BluetoothPoweredOffError : LocalizedError {
    var localizedDescription: String {
        return "Bluetooth is not active"
    }
    var errorDescription: String? {
        return localizedDescription
    }
}

extension BluetoothError: LocalizedError {
    public var errorDescription: String? {
        return localizedDescription
    }
}


class BLEService {

    static var shared = BLEService()
    
    let disposeBag = DisposeBag()
    let manager = BluetoothManager(queue: .main)

    
    init() {
    }

    private func discover() -> Observable<KulonService> {
        return manager.rx_state
            .do ( onNext: {
                if $0 == .poweredOff {
                    throw BluetoothPoweredOffError()
                }
            })
            .flatMap { _ -> Observable<Peripheral> in
               return self.manager
                    .scanForPeripherals(withServices: nil)
                    .timeout(30, scheduler: MainScheduler.instance)
//                .filter {
//                    $0.peripheral.identifier.uuidString == "43028998-0F95-40CE-85C2-98292FA48EA7"
//                }
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
            .timeout(15, scheduler: MainScheduler.instance)
            .take(1)
            .flatMap { service in
                service.first(where: { $0.uuid == DeviceService.imageService.uuid })!
                .discoverCharacteristics(nil)
            }
            .map {
                try KulonService($0)
            }
        
    }
    
    private func sendCommand(_ command: BLEControlCommand, to service: KulonService? = nil) -> Observable<(FileOperationResult, KulonService)> {
        //todo: use connect
        print("BLEService: Attempting to send comand: \(command)")
        if service != nil && service!.service.peripheral.isConnected {
            return  Observable.combineLatest(
                service!.notificationValueUpldated,
                    service!.control.writeValue(command.data, type: .withoutResponse)
                    .delaySubscription(3, scheduler: MainScheduler.instance)
                    )
                {
                    notificaction, control in
                    return (FileOperationResult(notificaction.value), service!)
            }

        }
        return discover()
            .flatMap { service in
                Observable.combineLatest(
                    service.notificationValueUpldated
                    .take(1),
                        service.control.writeValue(command.data, type: .withoutResponse).debug()
                        .delaySubscription(5, scheduler: MainScheduler.instance)
                    )
                    {
                    notificaction, control in
                        return (FileOperationResult(notificaction.value), service)
                    }
        }
        
    }
    
    func set(_ poshik: UploadablePoshik & NamedObject) -> Observable<Void> {
        return  sendCommand(.openImage(poshik.name))
            .flatMap { [unowned self] result, service -> Observable<Void> in
                print("Opening result: \(result)")
                switch result {
                case .opened:
                    return service.service.peripheral.cancelConnection().map{ _ in }
                // Observable.just()
                case  let .error(errorType):
                    switch errorType {
                    case .fileNotExist:
                        return self.upload(poshik, with: service)
                    case .decodingError, .resolutionError:
                        return Observable.error(ImageErorr())
                    case .undefined:
                        return Observable.error(DeviceError())
                    }
                case .undefined:
                    return Observable.error(DeviceError())
                }
            }
    }
    
    func upload(_ poshik: UploadablePoshik & NamedObject, with service: KulonService) -> Observable<Void> {
        
        let file = poshik.imageForUpload
        var counter = 0
        return sendCommand(.createImage(poshik.name), to: service)
            .flatMap { result, service -> Observable<Characteristic> in
                
                    file.asObservable().flatMap { file -> Observable<NSData> in
                        let chunkedFile = (file.data as NSData).chunked(of: 16)
                        print("file chunkscount: \(chunkedFile.count)")
                        return Observable.zip(
                            Observable.from(chunkedFile),
                            Observable<Int>.interval(0.02, scheduler: MainScheduler.instance).map{ _ in () }
                        ) { $0.0 }
                    }
                    .flatMap { chunk in
                        return service.upload.writeValue(Data(referencing: chunk) , type: .withResponse)
                    }
                    
                    .do(onNext: { _ in
                        print("chank loaded: \(counter)")
                        counter +=  1
                    })
                    .takeLast(1)
            }
            .flatMap { [unowned self] _ in
                self.sendCommand(.closeWriting, to: service)
            }
            .map { _ in }
    }
    
}
