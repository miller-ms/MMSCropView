//
//  MMSCropImageView.swift
//  Pods
//
//  Created by William Miller on 3/10/16.
//
//  Copyright (c) 2016 William Miller <support@millermobilesoft.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

import UIKit

open class MMSCropView: UIImageView, UIGestureRecognizerDelegate {

    
    /// The dragOrigin is the first point the user touched to begin the drag operation to delineate the crop rectangle.
    var dragOrigin = CGPoint.zero
    
    /// The rectangular view that the user sizes over the image to delineate the crop rectangle
    var cropView = UIView(frame: CGRect(x: -1.0, y: -1.0, width: -1.0, height: -1.0))
    
    /// Gesture recognizer for delineating the crop rectangle attached to the imageView
    var dragGesture = DragRecognizer()
    
    /// Tap gesture attached to the imageView when detected the cropView is hidden
    var hideGesture = UITapGestureRecognizer()
    
    /// Swallow gesture consumes taps inside the cropView without acting upon them.  This is required since without it taps in the crop view are handled by the tap gesture of the imageView.
    var swallowGesture = UITapGestureRecognizer()
    
    /// Moves an existing cropView around to any location over the imageView.
    var moveGesture = UIPanGestureRecognizer()
    
    /// The first touchpoint when the user began moving the cropView
    var touchOrigin = CGPoint.zero
    
    /// Layer that obscures the outside region of the crop rectangle
    var maskLayer = CAShapeLayer()
    
    /// Opacity for the shaded area outside the crop rectangle
    let shadedOpacity = Float(0.65)
    
    /// Opacity for the area under the crop rectangle is transparent
    let transparentOpacity = Float(0.0)
    
    /// The color for the shaded area outside the crop rectangle is black.
    let maskColor = (UIColor).black
    
    override public init(frame: CGRect) {
        
        super.init(frame: frame)
        
        initializeInstance()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        initializeInstance()
    }
    
    /**
     Initializes all the member views to present and operate on the cropView.
    */
    
     /**
     Initializes all the subviews and connects the gestures to the corresponding views and their action methods.
    */
    func initializeInstance() {
        
        // Enable user interaction
        isUserInteractionEnabled = true
        
        cropView.isHidden = true; // the cropView is modestly transparent
        
        cropView.backgroundColor =  UIColor.clear // background color is white
        
        cropView.alpha = 1.0 // the background is modestly transparent
        
        cropView.layer.borderWidth = 0.5 // the crop rectangle has a solid border
        
        cropView.layer.borderColor = UIColor.white.cgColor // the crop border is white
        
        addSubview(cropView) // add the cropView to the imageView
        
        dragGesture.addTarget(self, action: #selector(dragRectangle(_:)))
        
        dragGesture.delegate = self

        addGestureRecognizer(dragGesture)
        
        hideGesture.addTarget(self, action: #selector(hideCropRectangle(_:)))
        
        hideGesture.delegate = self;

        addGestureRecognizer(hideGesture)
        
        moveGesture.addTarget(self, action: #selector(moveRectangle(_:)))
        
        moveGesture.delegate = self
        
        cropView.addGestureRecognizer(moveGesture)
        
        cropView.addGestureRecognizer(swallowGesture)
        
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        maskLayer.fillColor = maskColor.cgColor
        
        maskLayer.opacity = transparentOpacity
        
        layer.addSublayer(maskLayer)
        
    }
    
    /**
     Creates two rectangular paths. One is set to the dimensions of the UIImageVie and a smaller one appended to the first that is the size and origin of the cropRect.
     
     - parameter mask     The shape layer added to the UIImageView
     - parameter cropRect The rectangular dimensions of area within the first shape to show transparent.
     
     - returns: returns the mask
     */
    func calculateMaskLayer (_ mask:CAShapeLayer, cropRect: CGRect) -> CAShapeLayer {
        
        // Create a rectangular path to enclose the circular path within the bounds of the passed in layer size.        
        let outsidePath = UIBezierPath(rect: bounds)
        
        let insidePath = UIBezierPath(rect: cropRect)
        
        outsidePath.append(insidePath)
        
        mask.path = outsidePath.cgPath;
        
        return mask

    }
    
    /**
     Always recognize the gesture.
     
     - parameter gestureRecognizer: An instance of a subclass of the abstract base class UIGestureRecognizer.
     
     - returns: returns true to recognize the gesture.
     */
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    /**
     The gesture delegate method to check if two gestures should be recognized simultaniously.  The tap and pan gestures are recognized simultaneously by the UIImageView.
     
     - parameter gestureRecognizer      An instance of a subclass of the abstract base class UIGestureRecognizer.  This is the object sending the message to the delegate.
     - parameter otherGestureRecognizer: An instance of a subclass of the abstract base class UIGestureRecognizer.
     
     - returns: Returns true to detect the tap gesture and pan gesture simultaneously.
     */
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        
        /* Enable to recognize the pan and tap gestures simultaneous for both the imageView and cropView
        */
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            
            return true
            
        } else {
            
            return false
        }
        
        
    }
    
    /**
     Checks if the bottom right corner and upper left corners of the input rectangle fall within boundary of the image frame. If either corner falls outside, it recalculates the respective origin's coordinate that falls outside the boundary to keep the rectangle witin the frame.  To restrict the move, the origin is always adjusted to maintain the size.
     
     - parameter cropFrame A rectangle representing the crop frame to check.
     
     - returns: returns the input rectangle unchanged if all the dimensions fall within the image frame; otherwise, a rectangle where the origin is recalculate to keep the rectangle within the boundary.
     */
    func restrictMoveWithinFrame (_ cropFrame: CGRect) -> CGRect {
        
        var restrictedFrame = cropFrame
        
        /* If the origin's y coordinate falls outside the image frame, recalculate it to fall on the boundary.
        */
        if restrictedFrame.origin.y < 0 {
            
            restrictedFrame.origin.y = 0
            
        }
        
        /* If the bottom right corner's y coordinate falls outside the image frame, recalculate the origin's y coordinate to fit the bottom right corner within the height boundary.
        */
        if (restrictedFrame.origin.y + restrictedFrame.height) > frame.height {
            
            restrictedFrame.origin.y = restrictedFrame.origin.y - (restrictedFrame.origin.y + restrictedFrame.height - frame.height)
            
        }
        
        /* If the origin's x coordinate falls outside the image frame, recalculate it to fall on the boundary.
        */
        if restrictedFrame.origin.x < 0 {
            
            restrictedFrame.origin.x = 0
            
        }
        
        /* If the bottom right corner's x coordinate falls outside the image frame, recalculate the origin's x coordinate to fit the bottom right corner within the width boundary.
        */
        if (restrictedFrame.origin.x + restrictedFrame.width) > frame.width {
            
            restrictedFrame.origin.x = restrictedFrame.origin.x - (restrictedFrame.origin.x + restrictedFrame.width - frame.width)
            
        }
        
        return restrictedFrame
        
    }
    
    /**
     A finger was touched within the boundaries of the crop view. It's responsible for repositioning the crop rectangle over the image based on the coordinates of touchpoint.
    
    - parameter gesture A reference to the pan gesture.
    */
    @IBAction func moveRectangle(_ gesture:UIPanGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.began {
            
            /*  save the crop view frame's origin to compute the changing position as the finger glides around the screen.  Also, save the first touch point compute the amount to change the frames orign.
            */
            touchOrigin = gesture.location(in: self)
            
            dragOrigin = cropView.frame.origin

        } else {
            
            /* Compute the change in x and y coordinates with respect to the original touch point.  Compute a new x and y point by adding the change in x and y to the crop view's origin before it was moved. Make this point the new origin.
            */
            
            let currentPt = gesture.location(in: self)
            
            let dx = currentPt.x - touchOrigin.x
            
            let dy = currentPt.y - touchOrigin.y
            
            cropView.frame = CGRect(x: dragOrigin.x+dx, y: dragOrigin.y+dy, width: cropView.frame.size.width, height: cropView.frame.size.height)

            cropView.frame = restrictMoveWithinFrame(cropView.frame)
            
            let _ = calculateMaskLayer(maskLayer, cropRect: cropView.frame)
            
        }
    }
    
    /**
     Checks if the bottom right corner and upper left corners of the input rectangle fall with in boundary of the image frame. If either corner falls outside, it resets the corner to fall on the boundary for the coordinate that lies outside.
     
     - parameter cropFrame A rectangle representing the crop frame to check.
     
     - returns: returns the input rectangle unchanged if all the dimensions fall within the image frame; otherwise, a rectangle where the coordinate falling outside the image frame is reset to fall on the boundary.
     */
    func restrictDragWithinFrame(_ cropFrame: CGRect) -> CGRect {
        
        var restrictedFrame = cropFrame
        
        
        /* if the origin's y coordinate falls outside the image frame, then move it to the boundary and reduce the height by the number of pixels it falls outside the frame.
        */
        if restrictedFrame.origin.y < 0 {
            
            restrictedFrame.size.height += restrictedFrame.origin.y
            
            restrictedFrame.origin.y = 0
            
        }
        
        /* if the bottom right corner's y coordinate falls outside the image frame, then move it to the boundary and reduce the height by the number of pixels it falls outside the frame.
        */
        if (restrictedFrame.origin.y + restrictedFrame.height) > frame.height {
            
            restrictedFrame = CGRect(x: restrictedFrame.origin.x, y: restrictedFrame.origin.y, width: restrictedFrame.width, height: frame.height - restrictedFrame.origin.y)
            
        }
        
        /* if the origin's x coordinate falls outside the image frame, then move it to the boundary and reduce the height by the number of pixels it falls outside the frame.
        */
        if restrictedFrame.origin.x < 0 {
            
            restrictedFrame.size.width += restrictedFrame.origin.x
            
            restrictedFrame.origin.x = 0
            
        }
        
        /* if the bottom right corner's x coordinate falls outside the image frame, then move it to the boundary and reduce the width by the number of pixels it falls outside the frame.
        */
        if (restrictedFrame.origin.x + restrictedFrame.width) > frame.width {
            
            restrictedFrame = CGRect(x: restrictedFrame.origin.x, y: restrictedFrame.origin.y, width: frame.width - restrictedFrame.origin.x, height: restrictedFrame.height)
            
        }
        
        return restrictedFrame
        
    }
        
    /**
    This method resizes the cropView frame as the user drags their finger across the UIImageView.  The first tap point becomes the frame's origin and is referenced through the pan duration to compute size and to set the frame's origin.
    
    - parameter gesture The gesture that is being recognized.
    */
    @IBAction func dragRectangle(_ gesture: DragRecognizer ) {
    
        var cropRect = CGRect.zero
    
        if gesture.state == UIGestureRecognizerState.began {
            
            /* set the origin for the remainder of the pan gesture to the first touchpoint.
            */
            cropView.isHidden = false
            
            maskLayer.opacity = shadedOpacity
            
            cropRect.origin = gesture.origin
            
            dragOrigin = gesture.origin
    
        } else {
            
            cropRect = cropView.frame
            
            let currentPoint = gesture.location(in: self)
            
            if currentPoint.x >= dragOrigin.x && currentPoint.y >= dragOrigin.y {
                
                /* finger is dragged down and right with respect to the origin start (Quadrant III);  cropViews origin is the original touchpoint.
                */
                cropRect.origin = dragOrigin
                
                cropRect.size = CGSize(width: currentPoint.x - cropRect.origin.x, height: currentPoint.y - cropRect.origin.y)
                
            } else if currentPoint.x <= dragOrigin.x && currentPoint.y <= dragOrigin.y {
                
                /* the finger is dragged up and left with respect to the origin start (Quadrant I); Since the frame origin always represents the upper left corner, the frame rectangle's origin is set to the current point, and the start origin is the bottom right corner.
                */
                cropRect.origin = currentPoint
                
                cropRect.size = CGSize(width: dragOrigin.x - currentPoint.x, height: dragOrigin.y - currentPoint.y)
                
            } else if currentPoint.x < dragOrigin.x {
                
                /* logic falls here when the x coordinate dimension is changing in the opposite direction of the y coordinate and moving down and to the left (Quadrant IV).  Thhe frame rectangle's origin is a combination of the current x coordinate and the start origin's y.
                */
                
                cropRect.origin = CGPoint(x: currentPoint.x, y: dragOrigin.y)
                
                cropRect.size = CGSize(width: dragOrigin.x - currentPoint.x, height: currentPoint.y - dragOrigin.y)
                
            } else if currentPoint.y < dragOrigin.y {
                
                /* Logic falls here when the y coordinate dimension is changing in the opposite direction of the y coordinate and moving up and to the right (Quadrant II). The frame rectangle's origin is a combination of the current y coordinate and the start origin's x.
                */

                cropRect.origin = CGPoint(x: dragOrigin.x, y: currentPoint.y)
                
                cropRect.size = CGSize(width: currentPoint.x - dragOrigin.x, height: dragOrigin.y - currentPoint.y)
                
            }
        }
        
        cropView.frame = restrictDragWithinFrame(cropRect)
        
        /*  The mask layer must move with the crop rectangle.
        */
        let _ = calculateMaskLayer(maskLayer, cropRect: cropView.frame)
    
    }
    
    /**
    The crop view becomes hidden when the user taps outside the crop view frame.
    
    - parameter gesture The gesture being recognized.
    */
    @IBAction func hideCropRectangle (_ gesture: UITapGestureRecognizer) {
        
        if !cropView.isHidden {
            
            cropView.isHidden = true
            
            maskLayer.opacity = transparentOpacity
            
            cropView.frame = CGRect(x: -1.0, y: -1.0, width: 0.0, height: 0.0)
        }
    }
    
    /* crop: returns a new UIImage cut from the crop view frame that overlays it.  The underlying CGImage of the returned UIImage has the dimensions of the crop view's frame.
    */

    /**
    Returns a new UIImage cut from the crop view frame that overlays it.  The underlying CGImage of the returned UIImage has the dimensions of the crop view's frame.
    
    ;returns: A UIImage having the pixels beneath the crop rectangle and its dimensions.
    */
    open func crop() -> UIImage {
        
        
        // Make sure the crop frame is within the bounds of the image.
        guard cropView.frame.origin.x >= 0 && cropView.frame.origin.y >= 0 && cropView.frame.height > 0 && cropView.frame.width > 0 && cropView.frame.origin.x + cropView.frame.width <= frame.width && cropView.frame.origin.y + cropView.frame.height <= frame.height else {
            return image!
        }
        
        let croppedImage = image!.cropRectangle(cropView.frame, inFrame:frame.size)
        
        return croppedImage
    }

}
