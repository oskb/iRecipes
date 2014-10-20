//
//  DataManager.swift
//  iRecipes
//
//  Created by Oskar Bævre on 10/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import Foundation
import CoreData

class DataManager
{
    class var sharedDataManager : DataManager {
    struct Singleton {
        static let instance = DataManager()
        }
        
        return Singleton.instance
    }
    
    let entityName = "Recipe"
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    private let sessionManager = AFHTTPSessionManager(baseURL: NSURL(string: "http://hyper-recipes.herokuapp.com"))
    private let imageCompressionRate = CGFloat(0.0)
    
    private var imageDownloadQueue : NSMutableArray = NSMutableArray()
    private var numberOfRequests = 0
    
    init()
    {
        self.sessionManager.requestSerializer = AFJSONRequestSerializer()
        self.sessionManager.responseSerializer = AFJSONResponseSerializer()
    }
    
    //MARK: WebService
    
    func isDownloadingImageForRecipe(recipe : Recipe) -> Bool
    {
        let recipeId : NSNumber = NSNumber(integer: recipe.id)
        return self.imageDownloadQueue.containsObject(recipeId)
    }
    
    func getRecipes(success:()->Void, failure:(error: NSError!)->Void)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            self.startNetworkLoadingIndicator()
            
            var recipeIdsOnServer = Array<Int>()
            let getString = "/recipes"
            
            self.sessionManager.GET(
                getString,
                parameters: nil,
                success: { (operation: NSURLSessionDataTask!,
                    responseObject: AnyObject!) in
                    
                    for i in 0..<responseObject.count
                    {
                        let recipeId = responseObject[i].objectForKey("id") as NSNumber
                        recipeIdsOnServer.append(recipeId.integerValue)
                        self.parseResponseObjectToRecipe(recipeId, responseObject: responseObject[i] as NSDictionary)
                    }
                    
                    self.stopNetworkLoadingIndicator()
                    self.deleteRecipesNotOnServer(recipeIdsOnServer)
                    self.saveManagedContext()
                    success()
                },
                failure: { (operation: NSURLSessionDataTask!,
                    error: NSError!) in
                    self.stopNetworkLoadingIndicator()
                    println("getRecipies failed: " + error.localizedDescription)
                    failure(error: error)
                }
            )
        }
    }
    
    func getImage(recipe:Recipe, success:()->Void, failure:(error: NSError!)->Void)
    {
        if !self.isDownloadingImageForRecipe(recipe)
        {
            let recipeId : NSNumber = NSNumber(integer: recipe.id)
            self.imageDownloadQueue.addObject(recipeId)
            self.startNetworkLoadingIndicator()
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                
                let request = AFHTTPRequestOperation(request: NSURLRequest(URL: NSURL(string: recipe.url!)))
                request.responseSerializer = AFImageResponseSerializer()
                
                request.setCompletionBlockWithSuccess({ (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                    
                    let image = responseObject as? UIImage
                    
                    if (self.objectStilExistsInStorage(recipe))
                    {
                        recipe.photo = UIImageJPEGRepresentation(image, self.imageCompressionRate);
                        self.saveManagedContext()
                    }
                    
                    self.stopNetworkLoadingIndicator()
                    self.imageDownloadQueue.removeObject(recipeId)
                    success()
                    
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        println("getImage failed: " + error.localizedDescription)
                        
                        self.stopNetworkLoadingIndicator()
                        self.imageDownloadQueue.removeObject(recipeId)
                        failure(error: error)
                })
                
                request.start()
            }
        }
    }
    
    func addRecipe(recipe:Recipe)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            self.startNetworkLoadingIndicator()
            
            let postString = "/recipes"
            let params = self.parameterDictionaryForRecipe(recipe)
            
            self.sessionManager.POST(postString, parameters: params, constructingBodyWithBlock: { (multipartFormData: AFMultipartFormData!) -> Void in
                
                if let imageData = recipe.photo
                {
                    multipartFormData.appendPartWithFileData(imageData, name: "recipe[photo]", fileName: "\(recipe.name).jpg", mimeType: "image/jpeg")
                }
                
                }, success: { (operation: NSURLSessionDataTask!,
                    responseObject: AnyObject!) -> Void in
                    
                    self.stopNetworkLoadingIndicator()
                    
                    if (self.objectStilExistsInStorage(recipe))
                    {
                        recipe.id = responseObject.objectForKey("id") as Int
                        self.saveManagedContext()
                    }
                    
                }) { (operation: NSURLSessionDataTask!,
                    error: NSError!) -> Void in
                    
                    self.stopNetworkLoadingIndicator()
                    println("addRecipe failed: " + error.localizedDescription)
            }
        }
    }
    
    func updateRecipe(recipe:Recipe)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
         
            let postString = "/recipes/\(recipe.id.integerValue)"
            let params = self.parameterDictionaryForRecipe(recipe)
            let urlString = "\(self.sessionManager.baseURL)\(postString)"
            let requestOperationManager = AFHTTPRequestOperationManager()
            var error : NSError?
            
            let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod("PUT", URLString: urlString, parameters: params, constructingBodyWithBlock: { (multipartFormData: AFMultipartFormData!) -> Void in
                
                if let imageData = recipe.photo
                {
                    multipartFormData.appendPartWithFileData(imageData, name: "recipe[photo]", fileName: "\(recipe.name).jpg", mimeType: "image/jpeg")
                }
                
                }, error: &error)
            
            self.startNetworkLoadingIndicator()
            
            let requestOperation = requestOperationManager.HTTPRequestOperationWithRequest( request, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                    self.stopNetworkLoadingIndicator()
                    self.saveManagedContext()
                
                }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    
                    self.stopNetworkLoadingIndicator()
                    println("updateRecipe failed: " + error.localizedDescription)
            }
            
            requestOperation.start()
        }
    }
    
    func deleteRecipe(recipe:Recipe)
    {
        let recipeId = recipe.id.integerValue
        self.removeLocalRecipe(recipe)
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
         
            self.startNetworkLoadingIndicator()
            
            let postString = "/recipes/\(recipeId)"
            self.sessionManager.DELETE(postString, parameters: nil, success: { (operation: NSURLSessionDataTask!,
                responseObject: AnyObject!) -> Void in
                
                    self.stopNetworkLoadingIndicator()
                    self.saveManagedContext()
                }) { (operation: NSURLSessionDataTask!,
                    error: NSError!) -> Void in
                    
                    self.stopNetworkLoadingIndicator()
                    println("deleteRecipe failed: " + error.localizedDescription)
            }
        }
    }
    
    private func parseResponseObjectToRecipe(recipeId : NSNumber, responseObject : NSDictionary)
    {
        let recipe = self.getExistingOrNewRecipe(recipeId)
        
        recipe.id = recipeId.integerValue
        recipe.name = responseObject.objectForKey("name") as String
        
        if let difficulty = responseObject.objectForKey("difficulty") as? String
        {
            recipe.difficulty = NSString(string:difficulty).integerValue
        }
        
        if let description = responseObject.objectForKey("description") as? String
        {
            recipe.descr = description
        }
        
        if let instructions = responseObject.objectForKey("instructions") as? String
        {
            recipe.instructions = instructions
        }
        
        if let favorite = responseObject.objectForKey("favorite") as? Bool
        {
            recipe.favorite = NSNumber(bool: favorite)
        }
        
        if let photo = responseObject.objectForKey("photo") as? Dictionary<String, String>
        {
            let urlString = photo["url"]!
            recipe.url = urlString
            recipe.photo = nil
        }
    }
    
    private func parameterDictionaryForRecipe(recipe : Recipe) -> Dictionary<String, AnyObject!>
    {
        var recipeParam = ["name" : recipe.name, "difficulty" : recipe.difficulty.integerValue] as Dictionary<String, AnyObject!>
        
        if let favorite = recipe.favorite
        {
            recipeParam.updateValue(recipe.favorite!.boolValue, forKey: "favorite")
        }
        
        if let description = recipe.descr
        {
            recipeParam.updateValue(description, forKey: "description")
        }
        
        if let instructions = recipe.instructions
        {
            recipeParam.updateValue(instructions, forKey: "instructions")
        }
        
        return ["recipe" : recipeParam]
    }
    
    private func startNetworkLoadingIndicator()
    {
        self.numberOfRequests++
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    private func stopNetworkLoadingIndicator()
    {
        if self.numberOfRequests > 0
        {
            self.numberOfRequests--
        }
        
        if self.numberOfRequests == 0
        {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    //MARK: CoreData
    
    func newRecipe()-> Recipe
    {
        let entityDescripition = NSEntityDescription.entityForName(entityName, inManagedObjectContext:self.managedObjectContext!)
        
        return Recipe(entity: entityDescripition!, insertIntoManagedObjectContext: self.managedObjectContext)
    }
    
    func removeLocalRecipe(recipe : Recipe)
    {
        if self.objectStilExistsInStorage(recipe)
        {
             self.deleteManagedObject(recipe)
        }
    }
    
    private func objectStilExistsInStorage(object : NSManagedObject) -> Bool
    {
        if (self.managedObjectContext?.existingObjectWithID(object.objectID, error: nil) != nil)
        {
            return true
        }
        return false
    }
    
    private func deleteRecipesNotOnServer(recipeIds : Array<Int>)
    {
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        let predicate = NSPredicate(format:"NOT (id IN %@)", recipeIds)
        fetchRequest.predicate = predicate
        
        var error : NSError?
        if let fetchedObjects = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error)
        {
            for object in fetchedObjects
            {
                if self.objectStilExistsInStorage(object as NSManagedObject)
                {
                    self.deleteManagedObject(object as NSManagedObject)
                }
            }
        }
    }
    
    private func getExistingOrNewRecipe(recipeId : NSNumber) -> Recipe
    {
        let fetchRequest = NSFetchRequest(entityName: self.entityName)
        let predicate = NSPredicate(format: "id == %@", recipeId)
        fetchRequest.predicate = predicate
        
        var error : NSError?
        if let fetchedObjects = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error)
        {
            if !fetchedObjects.isEmpty
            {
                return fetchedObjects[0] as Recipe
            }
        }
        return self.newRecipe()
    }
    
    private func deleteManagedObject(object:NSManagedObject)
    {
        self.managedObjectContext?.deleteObject(object)
        self.saveManagedContext()
    }
    
    private func saveManagedContext()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var error : NSError?
            
            if let hasChanges = self.managedObjectContext?.hasChanges
            {
                self.managedObjectContext?.save(&error)
                
                if error != nil
                {
                    println("Could not save context \(error?.localizedDescription)")
                }
            }
        })
    }
}