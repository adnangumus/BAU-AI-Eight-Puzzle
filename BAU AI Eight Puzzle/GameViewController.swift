//
//  GameViewController.swift
//  BAU AI Eight Puzzle
//
//  Created by cambaz on 21/10/15.
//  Copyright (c) 2015 Adnan Gümüş. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, AKPickerViewDataSource, AKPickerViewDelegate {
    // The scene draws the tiles and cookie sprites, and handles swipes.
    let titles = ["AStarSearch", "BFSearch", "DFSearch", "IDSearch","UCSearch","GreedySearch"]
    var scene: GameScene!
    var selectedIndex = 0
    // The level contains the tiles, the cookies, and most of the gameplay logic.
    // Needs to be ! because it's not set in init() but in viewDidLoad().
    var level: Level!
    var levelGoal: Level!
    //var activityIndicatorView:NVActivityIndicatorView!
    @IBOutlet var pickerView: AKPickerView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont(name: "DIN Condensed", size: 20.0)!
        self.pickerView.highlightedFont = UIFont(name: "DIN Condensed", size: 20)!
        self.pickerView.textColor = UIColor.gray
        self.pickerView.highlightedTextColor = UIColor.white
        self.pickerView.pickerViewStyle = .wheel
        self.pickerView.maskDisabled = false
        self.pickerView.reloadData()
        
        Helper.sharedInstance.events.listenTo(eventName: "cost", action: onCost)
        Helper.sharedInstance.events.listenTo(eventName: "nodes", action: onNodes)
        Helper.sharedInstance.events.listenTo(eventName: "depth", action: onDepth)
        Helper.sharedInstance.events.listenTo(eventName: "state", action: onStateChanged)
        Helper.sharedInstance.events.listenTo(eventName: "alert", action: onAlert)
        Helper.sharedInstance.events.listenTo(eventName: "isProcessing", action: onProcessing)
        
//        let frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 20, height: 20)
//        //activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallRotate, color: UIColor(red: 73.0/255.0, green: 191.0/255.0, blue: 73.0/255.0, alpha: 1.0))
//        self.view.addSubview(activityIndicatorView)
       
        
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = true
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .fill
        
        // Load the level.
        levelGoal = Level(filename: "Level_4")
        level = Level(filename: "Level_4")
        scene.levelGoal = levelGoal
        scene.level = level
        scene.addTilesGoal()
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        
        // Present the scene.
        skView.presentScene(scene)
        // Let's start the game!
        beginGame()
    }
    
    func beginGame() {
        shuffle()
    }
    
    func getBoard(_ l: Level!) -> [Int]{
        var array = [Int]()
        for j in (0 ..< 3){
            for i in (0 ..< 3){
                let tile = l.numberAtColumn(i+3, row: j+3)
                
                if tile != nil{
                    array.append(((tile?.value)!))
                }
            }
        }
        return array
    }
    
    func shuffle() {
        
        scene.removeAllNumbers()
        scene.removeAllNumbersGoal()
        
        levelGoal = Level(filename: "Level_4")
        level = Level(filename: "Level_4")
        scene.levelGoal = levelGoal
        scene.level = level
        scene.addTilesGoal()
        scene.addTiles()

        
        // Fill up the level with new cookies, and create sprites for them.
        let newNumbers = level.shuffle()
        let newNumbersGoal = levelGoal.shuffle()
        
        scene.addNumbersGoal(newNumbersGoal)
        scene.addNumbers(newNumbers)
    }
    
    // This is the swipe handler. MyScene invokes this function whenever it
    // detects that the player performs a swipe.
    func handleSwipe(_ swap: Swap) {
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func InitializeLabels(){
        scoreLabel.text = "----"
        targetLabel.text = "----"
        movesLabel.text = "----"
    }
    
    func onStateChanged(_ information:Any?){
        if let info = information as? [Int] {
            
            let row = Int(floor(Double(Int(info[0]) / 3)))
            let col = Int(info[0]) % 3
            
            let row2 = Int(floor(Double(Int(info[1]) / 3)))
            let col2 = Int(info[1]) % 3
            DispatchQueue.main.async(execute: {
                self.scene.swipe(col + 3, fromRow: row + 3, toColumn: col2 + 3, toRow: row2 + 3)
            })
        }
    }
    
    func onNodes(_ information:Any?){
        if let info = information as? String {
            DispatchQueue.main.async {
                self.scoreLabel.text = info
            }
        }
    }
    
    func onDepth(_ information:Any?){
        if let info = information as? String {
            DispatchQueue.main.async {
                self.movesLabel.text = info
            }
        }
    }
    
    func onCost(_ information:Any?){
        if let info = information as? String {
            DispatchQueue.main.async {
                self.targetLabel.text = info
            }
        }
    }
    
    func onAlert(_ information:Any?){
        if let info = information as? String {
            DispatchQueue.main.async {
                SweetAlert().showAlert("Sorry!", subTitle: info, style: AlertStyle.error)
            }
        }
    }
    
    func onProcessing(_ information:Any?){
        if let info = information as? Bool {
            DispatchQueue.main.async {
                if info == false {
                    //self.activityIndicatorView.stopAnimation()
                    
                    self.btnStart.tag = 0
                    self.btnStart.setTitle("Find Solution", for: UIControlState())
                }
                else{
                    self.btnStart.tag = 1
                    self.btnStart.setTitle("Stop Searching", for: UIControlState())
                    //self.activityIndicatorView.startAnimation()
                }
            }
        }
    }
    
    @IBAction func shuffleButtonTapped(_: AnyObject) {
        stopSearch()
        shuffle()
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton!) {
        if btnStart.tag == 0{
            startSearch()
        }
        else {
            stopSearch()
        }
    }
    
    func stopSearch(){
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            switch (self.selectedIndex){
            case 0:
                AStarSearch.sharedInstance.stopSearch()
                break;
            case 1:
                BFSearch.sharedInstance.stopSearch()
                break;
            case 2:
                DFSearch.sharedInstance.stopSearch()
                break;
            case 3:
                IDSearch.sharedInstance.stopSearch()
                break;
            case 4:
                UCSearch.sharedInstance.stopSearch()
                break;
            case 5:
                GBFSearch.sharedInstance.stopSearch()
                break;
            default:
                break;
            }
        }
        InitializeLabels()
        btnStart.tag = 0
        btnStart.setTitle("Find Solution", for: UIControlState())
    }
    
    func startSearch(){
        let board = getBoard(level) //[0,2,3,1,4,5,8,7,6]
        let goal = getBoard(levelGoal) //[1,2,3,4,5,6,0,8,7]
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            switch (self.selectedIndex){
            case 0:
                AStarSearch.sharedInstance.search(board, goal: goal, heuristic: "o")
                break;
            case 1:
                BFSearch.sharedInstance.search(board, goal: goal)
                break;
            case 2:
                DFSearch.sharedInstance.search(board, goal: goal)
                break;
            case 3:
                IDSearch.sharedInstance.search(board, goal: goal)
                break;
            case 4:
                UCSearch.sharedInstance.search(board, goal: goal)
                break;
            case 5:
                GBFSearch.sharedInstance.search(board, goal: goal)
                break;
            default:
                break;
            }
        }
        InitializeLabels()
        btnStart.tag = 1
        btnStart.setTitle("Stop Searching", for: UIControlState())
    }
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return self.titles.count
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.titles[item]
    }
    
    func pickerView(_ pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
        return UIImage(named: self.titles[item])!
    }
    
    // MARK: - AKPickerViewDelegate
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        selectedIndex = item
    }
}
