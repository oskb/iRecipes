//
//  Recipe.swift
//  iRecipes
//
//  Created by Oskar Bævre on 01/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import Foundation
import CoreData

class Recipe: NSManagedObject
{

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var difficulty: NSNumber
    @NSManaged var descr: String?
    @NSManaged var favorite: NSNumber?
    @NSManaged var instructions: String?
    @NSManaged var url: String?
    @NSManaged var photo: NSData?

}
