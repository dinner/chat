//
//  Mes+CoreDataProperties.swift
//  chat
//
//  Created by zhanglingxiang on 17/4/11.
//  Copyright © 2017年 zhanglingxiang. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Mes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mes> {
        return NSFetchRequest<Mes>(entityName: "Mes");
    }

    @NSManaged public var author: String?
    @NSManaged public var content: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var from: String?
    @NSManaged public var to: String?
    @NSManaged public var type: Int16

}
