//
//  GraphView.swift
//  Sensors
//
//  Created by Linda Cobb on 9/22/14.
//  Copyright (c) 2014 TimesToCome Mobile. All rights reserved.
//

import Foundation
import UIKit
import Accelerate



class GraphView: UIView
{
 
    var area: CGRect!
    var maxPoints: Int!
  
    var height:Float!
    var middle:Float!
    var dataArrayAltimeter:[Float]!
    var dataArrayPressure:[Float]!

    
    var currentPoints:Int = 0
    var previousX:CGFloat = 0.0
    var previousY:CGFloat = 0.0
    var px: CGPoint = CGPointMake(0.0, 0.0)
    var py: CGPoint = CGPointMake(0.0, 0.0)
    var mark: CGFloat = 0.0
    var altimeterScale:Float = 1.0
    var pressureScale:Float = 1.0
    
    
    
    
    required init( coder aDecoder: NSCoder ){
        super.init(coder: aDecoder)
    }

    
    override init(frame:CGRect){
        
        super.init(frame:frame)
    }
    
    

    func setupGraphView(){
    
    
        area = frame
        maxPoints = Int(area.size.width)
        height = Float(frame.height)
        middle = height / 2.0
        
        dataArrayAltimeter = [Float](count:maxPoints, repeatedValue: 0.0)
        dataArrayPressure = [Float](count:maxPoints, repeatedValue: 0.0)
    
    
    }



    
    func addXY( x: Float, y: Float ){
        
        if currentPoints < maxPoints { currentPoints++ }

        dataArrayAltimeter.insert(x, atIndex: 0)
        dataArrayAltimeter.removeLast()
        
        dataArrayPressure.insert(y, atIndex: 0)
        dataArrayPressure.removeLast()
        
        self.setNeedsDisplay()
    }
    
    
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
      
       
        // re calculate scale every 10 points or so
        if  currentPoints % 10 == 0 && currentPoints > 0 {
            // calculate scale
            var pressureDiff = abs (dataArrayPressure[0] - dataArrayPressure[currentPoints-1])
            pressureScale =  middle / pressureDiff
        
            var altimeterDiff = abs (dataArrayAltimeter[0] - dataArrayAltimeter[currentPoints-1])
            altimeterScale  = middle / altimeterDiff
        }
        
        
        
        // scale data so we can see tiny differences
        var scaledPressureData = [Float](count:maxPoints, repeatedValue: 0.0)
        var scaledAltimeterData = [Float](count:maxPoints, repeatedValue: 0.0)
        
        vDSP_vsmul( dataArrayAltimeter, 1, &altimeterScale, &scaledAltimeterData, 1, vDSP_Length(maxPoints))
        vDSP_vsmul( dataArrayPressure, 1, &pressureScale, UnsafeMutablePointer<Float>(scaledPressureData), 1, vDSP_Length(maxPoints))
        
    
        
      
        // loop vars
        var x:CGFloat = 0.0
        var y:CGFloat = 0.0
        
        
        for i in 0..<maxPoints {
            
            mark = CGFloat(i)
            

            // plot x
            CGContextSetStrokeColor(context, [0.0, 0.0, 1.0, 1.0])
            x = CGFloat(middle) - CGFloat(scaledPressureData[i]) % CGFloat(height)  // recenter and invert
            px.x = mark
            px.y = x
        
            CGContextMoveToPoint(context, mark-1.0, previousX)
            CGContextAddLineToPoint(context, mark, x)
            CGContextStrokePath(context)
            previousX = x
            
            // plot y
            CGContextSetStrokeColor(context, [1.0, 0.0, 0.0, 1.0])
            y = CGFloat(middle) - CGFloat(scaledAltimeterData[i]) % CGFloat(height)  // recenter and invert
            py.x = mark
            py.y = y
            
            CGContextMoveToPoint(context, mark-1.0, previousY)
            CGContextAddLineToPoint(context, mark, y)
            CGContextStrokePath(context)
            previousY = y
        }
    }
    
    
}