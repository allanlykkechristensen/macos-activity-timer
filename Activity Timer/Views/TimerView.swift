//
//  TimerView.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 12/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Cocoa
import AppKit

/// ⏰ TimerView is a custom view containing the rendering of the pie chart representing the spent and remaining time.
@IBDesignable class TimerView : NSView {
    
    enum Constants {
        /// Circumference of a perimeter
        static let perimeter = CGFloat(2*Double.pi)
        /// Full rotation in degrees, i.e. 360 degrees
        static let fullRotation = CGFloat(360);
    }
    
    
    /// Public property containing the percent of time remaining, expressed as a decimal number. When the property is updated the view will be notified to redrawn.
    /// - Postcondition: Percent is updated and notification sent to update view
    @IBInspectable var timeRemaining: Double = 0.0 {
        didSet {
            self.needsDisplay = true
        }
    }
    
    /// Public property containing the total time that should be countet down. When the property is set, the intervals to display on the timer is computed and stored in the intervals property.
    @IBInspectable var totalTime: Double = 60.0 {
        didSet {
            self.intervals = [String]()
            let minutesRemaining = floor(totalTime / 60)
            let secondsRemaining = floor(minutesRemaining * 60)+totalTime.truncatingRemainder(dividingBy: 60.0)
            let numbersToDisplay = 12
            
            let steps = secondsRemaining/Double(numbersToDisplay)
            
            for i in 1...numbersToDisplay {
                let theNumber = Double(i) * steps
                
                let minutesRemaining = floor(theNumber / 60)
                let secondsRemaining = theNumber - (minutesRemaining * 60)
                let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
                let display = "\(Int(minutesRemaining)):\(secondsDisplay)"
                
                self.intervals.append(display)
            }
        }
    }
    
    /// Public property determining if the icon in the middle of the timer should appear as if the timer is running (true) or is stopped (false).
    var started = false {
        didSet {
            self.needsDisplay = true
        }
    }
    
    /// Margin from the clock face outer circle to the time remaining pie chart
    @IBInspectable var marginToClockFace: CGFloat = 15.0
    /// Margin from the clock face outer circle to the time remaining pie chart
    @IBInspectable var marginToMinorSecondMarker: CGFloat = 10.0
    @IBInspectable var marginToMajorSecondMarker: CGFloat = 15.0
    @IBInspectable var majorSecondMarkerWidth: CGFloat = 2.5
    @IBInspectable var minorSecondMarkerWidth: CGFloat = 1.0
    @IBInspectable var markerColor: NSColor = NSColor.black
    @IBInspectable var backgroundColor: NSColor = NSColor.white
    @IBInspectable var roundedBorderColor: NSColor = NSColor.black
    @IBInspectable var roundedBorderThickness: CGFloat = 10
    @IBInspectable var roundedBorderRadius: CGFloat = 40
    @IBInspectable var timeRemainingColor: NSColor = NSColor.red
    
    // MARK: - Clock hand properties
    
    /// The radius of the dot in the middle, part of the clock hand
    @IBInspectable var clockHandDotRadius: CGFloat = 25
    /// The length of the pointer from the radius of the dot in the middle towards the clock ring
    @IBInspectable var clockHandPointerLength: CGFloat = 20
    /// Thickness of the clock hand pointer
    @IBInspectable var clockHandPointerWidth: CGFloat = 10
    /// Color of the clock hand dot and pointer
    @IBInspectable var clockHandColor: NSColor = NSColor.black
    /// Color of the play-state icon in the clock hand dot
    @IBInspectable var clockHandStateIconColor: NSColor = NSColor.white
    
    // MARK: - Clock face properties
    
    // Font used to display the clock face (numbers)
    @IBInspectable var clockFaceText: NSFont = NSFont(name: "Arial Rounded MT Bold", size: 18)!
    
    // Color of the font used to display the clock face (numbers)
    @IBInspectable var clockFaceColor: NSColor = NSColor.black
    
    
    // MARK: - Calculated properties
    
    /// Calculated private property returning the center of the circle as as CGPoint. This is used to draw all elements in the view.
    private var viewCenter : CGPoint {
        get {
            return CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        }
    }
    
    /// Calculated private property returning the origin of the coordination system (i.e. 0,0)
    private var origin : CGPoint {
        get {
            return CGPoint(x: 0, y:0)
        }
    }
    
    private var intervals = [String]()
    
    /// MARK: - Overriden NSView Methods
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current?.cgContext
        drawTimer(context: context)
        drawRemainingTime(context: context)
        drawBorder(rect: dirtyRect)
        drawClockHand(context: context)
        
        // TODO: Implement preference to toggle number display
        // FIXME: Get rid of magic numbers
        drawSecondMarkersText(rect: dirtyRect, context: context, radius: min(frame.size.width, frame.size.height) * 0.4, sides: 60, color: NSColor.black)
        
        self.layer?.backgroundColor = backgroundColor.cgColor
        
    }
}

// MARK: - Drawing Extension

extension TimerView {
    
    /// Draws the clock hand consisting of a fat dot in the middle with the state of the timer (started/paused) and with a line potining in the direction of the time remaining.
    func drawClockHand(context: CGContext?) {
        drawClockHandDot(context: context)
        drawClockHandPointer(context: context)
        drawClockHandState(context: context)
    }
    
    /// Draws the clock rounded borders
    func drawBorder(rect: NSRect) {
        // Set the color of the border
        roundedBorderColor.setStroke()
        
        let newRect = NSRect(x: rect.origin.x+2, y: rect.origin.y+2, width: rect.size.width-3, height: rect.size.height-3)
        let borderPath = NSBezierPath(roundedRect: newRect, xRadius: roundedBorderRadius, yRadius: roundedBorderRadius)
        borderPath.lineWidth = roundedBorderThickness
        borderPath.stroke()
    }
    
    /// Draws the clock face including the markers
    func drawTimer(context: CGContext?) {
        // FIXME: Get rid of magic numbers
        let radius = min(frame.size.width, frame.size.height) * 0.4 - roundedBorderRadius
        context?.addArc(center: viewCenter, radius: radius, startAngle: 0, endAngle:Constants.perimeter, clockwise: true)
        context?.setFillColor(NSColor.white.cgColor)
        context?.setStrokeColor(NSColor.black.cgColor)
        context?.setLineWidth(4.0)
        context?.fillPath()
        
        drawSecondMarkers(context: context, x: self.viewCenter.x, y: self.viewCenter.y, radius: radius, sides: 60, color: markerColor)
    }
    
    func drawSecondMarkers(context: CGContext?, x:CGFloat, y:CGFloat, radius:CGFloat, sides: Int, color:NSColor) {
        let points = circleCircumferencePoints(sides: sides, circleCenter: CGPoint(x: x, y: y), radius: radius)
        var divider: CGFloat = 1/16
        var lineWidth = majorSecondMarkerWidth
        for (index, value) in points.enumerated() {
            if index % 5 == 0 {
                divider=1/8
                lineWidth = majorSecondMarkerWidth
            } else {
                divider=1/16
                lineWidth = minorSecondMarkerWidth
            }
            let path = CGMutablePath()
            let xn = value.x + divider * (x-value.x)
            let yn = value.y + divider * (y-value.y)
            path.move(to: value)
            path.addLine(to: CGPoint(x:xn, y:yn))
            path.closeSubpath()
            context?.addPath(path)
            context?.setLineWidth(lineWidth)
            context?.setStrokeColor(color.cgColor)
            context?.strokePath()
        }
    }
    
    func drawSecondMarkersText(rect:CGRect, context: CGContext?, radius:CGFloat, sides: Int, color:NSColor) {
        guard intervals.count > 0 else { return }
        
        // Adjust -60 degrees (i.e. 2 major ticks on the clock face)
        let points = circleCircumferencePoints(sides: sides, circleCenter: viewCenter, radius: radius, adjustment: -60)
        
        var i = intervals.count-1;
        
        for (index, value) in points.enumerated() {
            if index > 0 && index % 5 == 0 {
                let textFontAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: self.clockFaceText, NSAttributedStringKey.foregroundColor: self.clockFaceColor ]
                
                // Determine x,y for a centered display of the text
                let text = CFAttributedStringCreate(nil, intervals[i] as CFString, textFontAttributes as CFDictionary)
                let line = CTLineCreateWithAttributedString(text!)
                let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
                let textX = value.x - bounds.width/2
                let textY = value.y - bounds.midY
                
                // Draw the text
                intervals[i].draw(at: CGPoint(x: textX, y: textY), withAttributes: textFontAttributes)
                i-=1
            }
        }
    }
    
    /// Draws the pie chart representing the remaining time.
    func drawRemainingTime(context: CGContext?) {
        let radius = min(frame.size.width, frame.size.height) * 0.4 - marginToClockFace - roundedBorderRadius
        let startAngle = CGFloat.pi / 2
        
        context?.setFillColor(timeRemainingColor.cgColor)
        let endAngle = startAngle + Constants.perimeter * CGFloat(timeRemaining)
        context?.move(to: viewCenter)
        context?.addArc(center: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context?.fillPath()
    }
    
    /// Draws the dot in the middle of the clock hand.
    func drawClockHandDot(context: CGContext?) {
        context?.addArc(center: self.viewCenter, radius: self.clockHandDotRadius, startAngle: 0, endAngle:Constants.perimeter, clockwise: true)
        context?.setFillColor(self.clockHandColor.cgColor)
        context?.fillPath()
    }
    
    /// Draw clock hand pointer in the direction of the time remaining.
    func drawClockHandPointer(context: CGContext?) {
        // To point in the right direction the context is rotated in the direction of the time remaining
        context?.saveGState()
        context?.translateBy(x: viewCenter.x, y: viewCenter.y)
        context?.rotate(by: CGFloat(timeRemaining) * degree2radian(Constants.fullRotation))
        
        // Draw pointer
        let path = CGMutablePath()
        path.move(to: self.origin)
        path.addLine(to: CGPoint(x: self.origin.x, y: self.clockHandDotRadius + self.clockHandPointerLength))
        context?.addPath(path)
        context?.setStrokeColor(self.clockHandColor.cgColor)
        context?.setLineWidth(self.clockHandPointerWidth)
        context?.strokePath()
        
        // Restore context to original state/position
        context?.restoreGState()
    }
    
    /// Draws the state of the timer in the cloch hand dot.
    func drawClockHandState(context: CGContext?) {
        let iconHeight = CGFloat(10)
        let iconPauseSpacing = CGFloat(3)
        
        context?.setFillColor(self.clockHandStateIconColor.cgColor)
        context?.setStrokeColor(self.clockHandStateIconColor.cgColor)
        if (!started) {
            context?.move(to: viewCenter)
            context?.addLine(to: CGPoint(x: viewCenter.x, y:viewCenter.y + iconHeight/2))
            context?.addLine(to: CGPoint(x: viewCenter.x+iconHeight/2, y:viewCenter.y))
            context?.addLine(to: CGPoint(x: viewCenter.x, y:viewCenter.y - iconHeight/2))
            context?.closePath()
            context?.strokePath()
        } else {
            context?.move(to: CGPoint(x: viewCenter.x-iconPauseSpacing, y: viewCenter.y-iconHeight))
            context?.addLine(to: CGPoint(x: viewCenter.x-iconPauseSpacing, y:viewCenter.y + iconHeight))
            context?.move(to: CGPoint(x: viewCenter.x+iconPauseSpacing, y: viewCenter.y-iconHeight))
            context?.addLine(to: CGPoint(x: viewCenter.x+iconPauseSpacing, y:viewCenter.y + iconHeight))
            
            context?.strokePath()
        }
    }
}

// MARK: - Calculations Extension

extension TimerView {
    
    /**
     Converts degrees to radian (pi * degree / 180).
     - parameter degree: Degrees to convert to radian
     - returns: Radian of the given degree
     */
    func degree2radian(_ degree:CGFloat)->CGFloat {
        return CGFloat(Double.pi) * degree/180
    }
    
    
    /**
     Calculates equal spaced points around the circumference of the circle.
     
     - parameter sides: Number of points to calculate
     - parameter circleCenter: Center point of the circle
     - parameter radius: Radius at which to calculate the points from the circle center
     - parameter adjustment: Degree adjustment of the points, defaults to 0 degrees
     - returns: Array of CGPoint equally distributed around the circumferences of the circle
     */
    func circleCircumferencePoints(sides: Int, circleCenter:CGPoint, radius: CGFloat, adjustment:CGFloat=0) -> [CGPoint] {
        let angle = degree2radian(Constants.fullRotation/CGFloat(sides))
        let cx = circleCenter.x
        let cy = circleCenter.y
        let r = radius
        var i = sides
        var points = [CGPoint]()
        
        while points.count <= sides {
            let xpo = cx-r * cos(angle * CGFloat(i)+degree2radian(adjustment))
            let ypo = cy-r * sin(angle * CGFloat(i)+degree2radian(adjustment))
            
            points.append(CGPoint(x:xpo,y:ypo))
            i-=1;
        }
        
        return points
    }
}
