//
//  StandardSectionModel.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 23/08/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxDataSources

struct StandardSectionModel<T>: SectionModelType {
    var items: [T]
    
    init(original: StandardSectionModel<T>, items: [T]) {
        self = original
        self.items = items
    }
    
    init(items: [T]) {
        self.items = items
    }
    
}
