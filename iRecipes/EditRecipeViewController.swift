//
//  EditRecipeViewController.swift
//  iRecipes
//
//  Created by Oskar Bævre on 15/10/14.
//  Copyright (c) 2014 123. All rights reserved.
//

import UIKit

class EditRecipeViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, EditNameViewDelegate, EditDifficultViewDelegate
{
    private let imagePicker = UIImagePickerController()
    private let dataManager = DataManager.sharedDataManager
    
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    
    private var recipe : Recipe?
    private var photoView : EditPhotoView?
    private var nameView : EditNameView?
    private var difficultyView : EditDifficultyView?
    private var descriptionView : EditDescriptionInstructionView?
    private var instructionsView : EditDescriptionInstructionView?
    var isImageLoading = false
    
    init(recipe : Recipe)
    {
        super.init(nibName: nil, bundle: nil)
        self.recipe = recipe
    }
    
    override init()
    {
        super.init(nibName: nil, bundle: nil)
        self.recipe = self.dataManager.newRecipe()
        self.recipe?.name = ""
        self.recipe?.difficulty = NSNumber.numberWithInt(1)
        self.recipe?.favorite = false
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.addNavigationBarButtons()
        self.addScrollView()
        self.addPhotoView()
        self.addNameView()
        self.addDifficultyView()
        self.addDescriptionView()
        self.addInstructionsView()
        
        self.disableSaveButtonIfRecipeHasNoName()
    }
    
    private func addNavigationBarButtons()
    {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "save")
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    private func addScrollView()
    {
        self.scrollView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 100.0)
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 5, self.scrollView.frame.size.height)
        self.scrollView.delegate = self
        self.scrollView.pagingEnabled = true
        self.scrollView.delaysContentTouches = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.scrollView)
        
        self.pageControl.frame = CGRectMake(0.0, self.scrollView.frame.size.height, self.scrollView.frame.size.width, 50.0)
        self.pageControl.numberOfPages = 5
        self.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        self.pageControl.currentPageIndicatorTintColor = self.pageControl.tintColor
        self.view.addSubview(self.pageControl)
    }
    
    private func addPhotoView()
    {
        self.photoView = EditPhotoView(frame: CGRectMake(0.0, 0.0, self.scrollView.frame.size.width, self.scrollView.contentSize.height))
        self.scrollView.addSubview(self.photoView!)
        
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "openCamera")
        self.photoView!.imageView.addGestureRecognizer(imageTapGestureRecognizer)
        
        if let photoData = self.recipe?.photo
        {
            self.photoView!.loadImageAnimated(photoData)
        }
        else if self.isImageLoading
        {
            self.photoView!.startImageLoadingIndicator()
        }
        else
        {
            self.photoView!.showPlaceholderImage()
        }
    }
    
    private func addNameView()
    {
        self.nameView = EditNameView(frame: CGRectMake(self.scrollView.frame.size.width, 0.0, self.scrollView.frame.size.width, self.scrollView.contentSize.height), delegate: self)
        self.scrollView.addSubview(self.nameView!)
        
        if let recipeName = self.recipe?.name
        {
            self.nameView!.setName(recipeName)
        }
    }
    
    private func addDifficultyView()
    {
        self.difficultyView = EditDifficultyView(frame: CGRectMake(self.scrollView.frame.size.width * 2, 0.0, self.scrollView.frame.size.width, self.scrollView.contentSize.height), delegate : self)
        self.difficultyView!.setSelectedButton(self.recipe!.difficulty)
        self.scrollView.addSubview(self.difficultyView!)
    }
    
    private func addDescriptionView()
    {
        self.descriptionView = EditDescriptionInstructionView(frame: CGRectMake(self.scrollView.frame.size.width * 3, 0.0, self.scrollView.frame.size.width, self.scrollView.contentSize.height),
            name: "Description:",
            text: self.recipe?.descr)
        self.scrollView.addSubview(self.descriptionView!)
    }
    
    private func addInstructionsView()
    {
        self.instructionsView = EditDescriptionInstructionView(frame: CGRectMake(self.scrollView.frame.size.width * 4, 0.0, self.scrollView.frame.size.width, self.scrollView.contentSize.height),
            name: "Instructions:",
            text: self.recipe?.instructions)
        self.scrollView.addSubview(self.instructionsView!)
    }
    
    private func disableSaveButtonIfRecipeHasNoName()
    {
        if self.recipe?.name == ""
        {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    private func isRecipeNew() -> Bool
    {
        return self.recipe?.id.integerValue == 0
    }
    
    private func removeRecipeIfNew()
    {
        if self.isRecipeNew()
        {
            self.dataManager.removeLocalRecipe(self.recipe!)
        }
    }
    
    private func setValuesOnRecipe()
    {
        self.recipe?.name = self.nameView!.name()
        
        if let image = photoView?.image()
        {
            self.recipe?.photo = UIImageJPEGRepresentation(image, 1.0)
        }
        
        if let descriptionText = self.descriptionView!.textViewText()
        {
            self.recipe?.descr = descriptionText
        }
        
        if let instructionText = self.instructionsView!.textViewText()
        {
            self.recipe?.instructions = instructionText
        }
    }
    
    func loadRecipeImageForRecipe(recipe : Recipe)
    {
        if recipe.id == self.recipe?.id
        {
            self.photoView?.stopImageLoadingIndicatorAndLoadImageAnimated(self.recipe?.photo)
        }
    }
    
    func startImageLoadingIndicator()
    {
        self.photoView?.startImageLoadingIndicator()
    }
    
    func cancel()
    {
        self.removeRecipeIfNew()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save()
    {
        self.setValuesOnRecipe()
        
        if self.recipe?.name != ""
        {
            if self.isRecipeNew()
            {
                self.dataManager.addRecipe(self.recipe!)
            }
            else
            {
                self.dataManager.updateRecipe(self.recipe!)
            }
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            self.disableSaveButtonIfRecipeHasNoName()
            UIAlertView(title: "Sorry...", message: "Can not save a recipe without a name", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            self.imagePicker.allowsEditing = false
            self.imagePicker.mediaTypes = NSArray(object: kUTTypeImage)
            self.imagePicker.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!)
    {
        self.photoView?.setImage(image)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let pageWidth = self.scrollView.frame.size.width
        let fractionOfPage = self.scrollView.contentOffset.x / pageWidth;
        let page = lround(Double(fractionOfPage))
        self.pageControl.currentPage = page
    }
    
    //MARK: EditNameViewDelegate
    
    func nameFieldNotEmpty()
    {
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func nameFieldIsEmpty()
    {
        self.navigationItem.rightBarButtonItem?.enabled = false
    }
    
    //MARK: EditDifficultyViewDelegate
    
    func difficultyChanged(difficulty: Int)
    {
        self.recipe?.difficulty = difficulty
    }
}

