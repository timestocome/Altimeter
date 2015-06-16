//
//  AltimeterViewController.swift
//  Sensors
//
//  Created by Linda Cobb on 9/22/14.
//  Copyright (c) 2014 TimesToCome Mobile. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion


// first reading is a zero, measures differences
// measures relative altitude change in meters
// measures pressure in kilopascals

class AltimeterViewController: UIViewController
{
    
    @IBOutlet var xLabel: UILabel!
    @IBOutlet var yLabel: UILabel!
    
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var startButton: UIButton!
    
    @IBOutlet var graphView: GraphView!

    
    let altimeter = CMAltimeter()
    var stopUpdates = false
    
    /*
    required init( coder aDecoder: NSCoder ){
        
        super.init(coder: aDecoder)

        println("decoder")
    }
    
    
    convenience override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!){
        println("override init")

        self.init(nibName: nil, bundle: nil)
    }
    
    
    convenience init() {
        println("convenience")

        self.init(nibName: nil, bundle: nil)
    }*/
    
    
    
    override func viewDidLoad() {
        graphView.setupGraphView()
    }
    
    
    
    
    @IBAction func stop(){
        
        stopUpdates = true
        self.altimeter.stopRelativeAltitudeUpdates()
    }
    
    
    
    @IBAction func start(){
        
        stopUpdates = false
        startUpdates()
    }
    
    
    
    func startUpdates(){
        
        
        if CMAltimeter.isRelativeAltitudeAvailable(){
            
            let dataQueue = NSOperationQueue()
            

            altimeter.startRelativeAltitudeUpdatesToQueue(dataQueue, withHandler: {
            
                data, error in
            
                NSOperationQueue.mainQueue().addOperationWithBlock({

                    self.xLabel.text = NSString(format: "Altitude: \(data.relativeAltitude) m") as String
                    self.yLabel.text = NSString(format: "Pressure: \(data.pressure) kilopacals") as String
                    
                    self.graphView.addXY(Float(data.relativeAltitude), y: Float(data.pressure))
                    
                    
                    if ( self.stopUpdates ){
                        self.altimeter.stopRelativeAltitudeUpdates()
                    }


                })
                
            })
        
            
        }
    }
    
    
    override func viewDidDisappear(animated: Bool){
        
        super.viewDidDisappear(animated)
        stop()
        
    }
    

}