//
//  RecipesViewController.swift
//  iRecipes
//
//  Created by Oskar Bævre on 29/09/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit
import CoreData

class RecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UISearchResultsUpdating
{
    private let dataManager = DataManager.sharedDataManager
    private let recipesTableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var recipeViewController : RecipeViewController?
    private var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()
    private var imageCache = NSCache()
    private var refreshControl = UIRefreshControl()
    private var showFavorites = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Recipes"
        view.backgroundColor = UIColor.whiteColor()
        
        self.addNavigationBarButtons()
        self.setupTableView()
        self.setupSearchController()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        
        if let selectedRowIndexPath = self.recipesTableView.indexPathForSelectedRow()
        {
            self.recipesTableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: true)
        }
        
        self.loadRecipesFromCoreDataAndRefreshTableView()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        if let navigationControllerDelegate = self.navigationController?.delegate
        {
            if navigationControllerDelegate.isEqual(self)
            {
                self.navigationController?.delegate = nil;
            }
        }
    }
    
    //MARK: Setup
    
    private func addNavigationBarButtons()
    {
        let newRecipeButton = UIBarButtonItem(title: "New", style: UIBarButtonItemStyle.Plain, target: self, action: "openEditRecipeViewController")
        self.navigationItem.rightBarButtonItem = newRecipeButton
        
        let favoriteOrAllButton = UIBarButtonItem(title: "Favorites", style: UIBarButtonItemStyle.Plain, target: self, action: "toggleShowFavoritesOrAll")
        self.navigationItem.leftBarButtonItem = favoriteOrAllButton
    }
    
    private func setupTableView()
    {
        self.recipesTableView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        self.recipesTableView.delegate = self
        self.recipesTableView.dataSource = self
        self.recipesTableView.separatorColor = UIColor.clearColor()
        self.recipesTableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.recipesTableView)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.recipesTableView.addSubview(refreshControl)
        
        self.loadRecipesFromCoreDataAndRefreshTableView()
    }
    
    private func setupSearchController()
    {
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.recipesTableView.frame), 44.0)
        self.recipesTableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.barTintColor = UIColor.whiteColor()
        
        self.recipesTableView.contentOffset = CGPointMake(0, self.searchController.searchBar.frame.height)
    }
    
    //MARK: Helpers
    
    private func dismissSearchController()
    {
        self.searchController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openEditRecipeViewController()
    {
        self.fetchedResultController.delegate = nil
        
        let editRecipeViewController = EditRecipeViewController()
        editRecipeViewController.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        let navigationController =
        UINavigationController(rootViewController: editRecipeViewController)
        
        self.dismissSearchController()
        self.navigationController?.presentViewController(navigationController!, animated: true, completion: nil)
    }
    
    func toggleShowFavoritesOrAll()
    {
        if self.navigationItem.leftBarButtonItem?.title == "Favorites"
        {
            self.navigationItem.leftBarButtonItem?.title = "All"
            self.showFavorites = true
        }
        else
        {
            self.navigationItem.leftBarButtonItem?.title = "Favorites"
            self.showFavorites = false
        }
        self.reLoadRecipesWithFadeAnimation()
    }
    
    private func reLoadRecipesWithFadeAnimation()
    {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.recipesTableView.alpha = 0.0
            }, completion: { (Bool) -> Void in
                
                self.loadRecipesFromCoreDataAndRefreshTableView()
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.recipesTableView.alpha = 1.0
                })
        })
    }
    
    func refresh()
    {
        self.dataManager.getRecipes({ () -> Void in
            
            self.refreshControl.endRefreshing()
            self.recipesTableView.reloadData()
            self.imageCache.removeAllObjects()
            
            }, failure: { (error: NSError!) -> Void in
                self.refreshControl.endRefreshing()
        })
    }
    
    private func recipeHasCachedImage(recipe : Recipe) -> UIImage?
    {
        return self.imageCache.objectForKey(recipe.id) as? UIImage
    }
    
    private func recipeHasImageData(recipe : Recipe) -> Bool
    {
        if let imageData = recipe.photo
        {
            return true
        }
        return false
    }
    
    private func recipeHasImageOnServer(recipe : Recipe) -> Bool
    {
        if let url = recipe.url
        {
            return true
        }
        return false
    }
    
    private func cellForRecipe(recipe : Recipe) -> RecipeCell?
    {
        var cell : RecipeCell?
        
        if let indexPath = self.fetchedResultController.indexPathForObject(recipe)
        {
            if let recipeCell = self.recipesTableView.cellForRowAtIndexPath(indexPath) as? RecipeCell
            {
                cell = recipeCell
            }
        }
        
        return cell
    }
    
    private func stopImageLoadingIndicatorOnCellForRecipe(recipe : Recipe)
    {
        if let cell = self.cellForRecipe(recipe)
        {
            cell.recipeImageView.stopImageLoadingIndicator()
        }
    }
    
    private func removeCachedImageForRecipeAtIndexPath(indexPath : NSIndexPath?)
    {
        if self.fetchedResultController.fetchedObjects?.count > indexPath?.row
        {
            if let recipe = fetchedResultController.objectAtIndexPath(indexPath!) as? Recipe
            {
                self.imageCache.removeObjectForKey(recipe.id)
            }
        }
    }
    
    private func downloadRecipeImageFromServer(recipe : Recipe)
    {
        self.dataManager.getImage(recipe, success: { () -> Void in
            
            self.stopImageLoadingIndicatorOnCellForRecipe(recipe)
            
            self.recipeViewController?.loadRecipeImageForRecipe(recipe)
            self.convertImageDataToCachedImageAndAddToCell(recipe)
            
            }, failure: { (error: NSError!) -> Void in
                
                self.stopImageLoadingIndicatorOnCellForRecipe(recipe)
        })
    }
    
    private func convertImageDataToCachedImageAndAddToCell(recipe : Recipe)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if let imageData = recipe.photo
            {
                if let rawImage = UIImage(data: imageData)
                {
                    let thumbnail = UIImage().thumbnailFromImage(rawImage, scaledToSize: CGSizeMake(120.0, 120.0))
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.imageCache.setObject(thumbnail, forKey: recipe.id)
                        
                        if let cell = self.cellForRecipe(recipe)
                        {
                            cell.recipeImageView.setImageAnimated(thumbnail)
                        }
                    })
                }
            }
        }
    }
    
    private func loadImageOnRecipeCell(cell : RecipeCell, recipe : Recipe)
    {
        if let image = self.recipeHasCachedImage(recipe)
        {
            cell.recipeImageView.image = image
        }
        else if self.recipeHasImageData(recipe)
        {
            self.convertImageDataToCachedImageAndAddToCell(recipe)
        }
        else if self.recipeHasImageOnServer(recipe)
        {
            cell.recipeImageView.startImageLoadingIndicator()
            
            if !self.dataManager.isDownloadingImageForRecipe(recipe)
            {
                self.downloadRecipeImageFromServer(recipe)
            }
        }
    }
    
    //MARK: TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.fetchedResultController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.fetchedResultController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 120.0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return UIView(frame: CGRectZero)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let recipe = self.fetchedResultController.objectAtIndexPath(indexPath) as Recipe
        let cellIdentifier = "recipeCell"
        
        var cell:RecipeCell? = self.recipesTableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? RecipeCell
        
        if cell == nil
        {
            cell = RecipeCell(reuseIdentifier: cellIdentifier)
        }
        
        cell!.recipeNameLabel.text = recipe.name
        cell!.recipeDescriptionLabel.text = recipe.descr
        cell!.recipeImageView.image = nil
        
        self.loadImageOnRecipeCell(cell!, recipe: recipe)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let recipe = fetchedResultController.objectAtIndexPath(indexPath) as Recipe
        self.recipeViewController = RecipeViewController(recipe: recipe)
        
        if self.dataManager.isDownloadingImageForRecipe(recipe)
        {
            self.recipeViewController?.startImageLoadingIndicator()
        }
        
        self.dismissSearchController()
        self.navigationController?.pushViewController(self.recipeViewController!, animated: true)
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!)
    {
        let recipe = fetchedResultController.objectAtIndexPath(indexPath) as Recipe
        self.dataManager.deleteRecipe(recipe)
    }
    
    //MARK: CoreData
    
    private func loadRecipesFromCoreDataAndRefreshTableView()
    {
        self.fetchedResultController = getFetchedResultController()
        self.fetchedResultController.delegate = self
        self.fetchedResultController.performFetch(nil)
        
        self.recipesTableView.reloadData()
    }
    
    private func getFetchedResultController() -> NSFetchedResultsController
    {
        self.fetchedResultController = NSFetchedResultsController(fetchRequest: self.recipesFetchRequest(), managedObjectContext: self.dataManager.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        return self.fetchedResultController
    }
    
    private func recipesFetchRequest() -> NSFetchRequest
    {
        let fetchRequest = NSFetchRequest(entityName: self.dataManager.entityName)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var requestPredicate : NSPredicate?
        
        let searchText = searchController.searchBar.text
        if searchText != ""
        {
            //If search text is not empty we only fetch the ones matching the search text
            if let predicate = NSPredicate(format: "name contains[cd] %@", searchText)
            {
                requestPredicate = self.compoundPredicates(requestPredicate, predicate2: predicate)
            }
        }
        
        if self.showFavorites
        {
            //If showFavorites is true, we want to only fetch the favorited ones
            if let predicate = NSPredicate(format: "favorite = YES")
            {
                requestPredicate = self.compoundPredicates(requestPredicate, predicate2: predicate)
            }
        }
        
        if let predicate = requestPredicate
        {
            fetchRequest.predicate = predicate
        }
        
        return fetchRequest
    }
    
    private func compoundPredicates(predicate1 : NSPredicate?, predicate2 : NSPredicate) -> NSPredicate
    {
        if let firstPredicate = predicate1
        {
            return NSCompoundPredicate.andPredicateWithSubpredicates([firstPredicate, predicate2])
        }
        else
        {
            return predicate2
        }
    }
    
    //MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        self.recipesTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        switch(type)
            {
        case NSFetchedResultsChangeType.Insert:
            self.recipesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            break
            
        case NSFetchedResultsChangeType.Delete:
            self.removeCachedImageForRecipeAtIndexPath(indexPath)
            self.recipesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Left)
            break
            
        case NSFetchedResultsChangeType.Update:
            self.removeCachedImageForRecipeAtIndexPath(indexPath)
            self.recipesTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Right)
            break
            
        case NSFetchedResultsChangeType.Move:
            self.recipesTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Left)
            self.recipesTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!)
    {
        self.recipesTableView.endUpdates()
    }
    
    //MARK: UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if toVC.isKindOfClass(RecipeViewController)
        {
            return RecipePresentationAnimator()
        }
        return nil
    }
    
    //MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        self.loadRecipesFromCoreDataAndRefreshTableView()
    }
}
