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
    @IBInspectable var timeRemainingColor: NSColor = NSColor.pieChartTimeRemainingFillColor
    
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
    
    /// MARK: - Overriden NSView Methods
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current?.cgContext
        drawTimer(context: context)
        drawRemainingTime(context: context)
        drawBorder(rect: dirtyRect)
        drawClockHand(context: context)
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
        let radius = min(frame.size.width, frame.size.height) * 0.5 - roundedBorderRadius
        context?.addArc(center: viewCenter, radius: radius, startAngle: 0, endAngle:Constants.perimeter, clockwise: true)
        context?.setFillColor(NSColor.white.cgColor)
        context?.setStrokeColor(NSColor.black.cgColor)
        context?.setLineWidth(4.0)
        context?.fillPath()
        
        // Add 60 markers on the clock face (like a normal analog clock)
        for i in 1...60 {
            context?.saveGState()
            // Translate and rotate into positon of next marker
            context?.translateBy(x: frame.midX, y: frame.midY)
            context?.rotate(by: degree2radian(CGFloat(i)*6))
            
            // Determine if it is a major or minor marker
            if i % 5 == 0 {
                drawSecondMarker(ctx: context, x: radius-marginToMajorSecondMarker, y:0, radius:radius, lineWidth: majorSecondMarkerWidth, color: markerColor)
            }
            else {
                drawSecondMarker(ctx: context, x: radius-marginToMinorSecondMarker, y:0, radius:radius, lineWidth: minorSecondMarkerWidth, color: markerColor)
            }
            
            context?.restoreGState()
        }
    }
    
    /// Draws a single second marker on the clock face
    func drawSecondMarker(ctx:CGContext?, x:CGFloat, y:CGFloat, radius:CGFloat, lineWidth:CGFloat, color:NSColor) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: x, y: y))
        path.closeSubpath()
        ctx?.addPath(path)
        ctx?.setLineWidth(lineWidth)
        ctx?.setStrokeColor(color.cgColor)
        ctx?.strokePath();
    }
    
    /// Draws the pie chart representing the remaining time.
    func drawRemainingTime(context: CGContext?) {
        let radius = min(frame.size.width, frame.size.height) * 0.5 - marginToClockFace - roundedBorderRadius
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
    
    /// Converts degrees to radian (pi * degree / 180)
    func degree2radian(_ degree:CGFloat)->CGFloat {
        return CGFloat(Double.pi) * degree/180
    }
    
}
