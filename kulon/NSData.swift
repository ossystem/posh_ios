//
//  NSData.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 10/08/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation

extension NSData{
    func chunked(of size: Int) -> [NSData]{
        
        if self.length <= size{
            return [self]
        }
        
        var result: [NSData] = []
        
        var index = 0
        
        repeat {
            let len = min(size, self.length - index)
            let subNSData = self.subdata(with: NSMakeRange(index, len))
            result.append(subNSData as NSData)
            index += size
        } while(index < self.length)
        
        return result
    }
}
