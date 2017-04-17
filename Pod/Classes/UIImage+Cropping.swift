//
//  UIImage+Cropping.swift
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

public extension UIImage {
    
    /**
    Calculates a return size by aspect scaling the fromSize to fit within the destination size while giving priority to the width or height depending on which preference will maintain both the return width and height within the destination ie the return size will return a new size where both width and height are less than or equal to the destinations.
    
    - parameter fromSize: Size to scale
    - parameter toSize:   Destination size
    
    - returns: Scaled size
    */
    class func scaleSize(_ fromSize: CGSize, toSize:CGSize) -> CGSize {
        
        var scaleSize = CGSize.zero
        
        if toSize.width < toSize.height {
            
            if fromSize.width >= toSize.width { // give priority to width if it is larger than the destination width
                
                scaleSize.width = round(toSize.width)
                
                scaleSize.height = round(scaleSize.width * fromSize.height / fromSize.width)
                
            } else if fromSize.height >= toSize.height { // then give priority to height if it is larger than destination height
                
                scaleSize.height = round(toSize.height)
                
                scaleSize.width = round(scaleSize.height * fromSize.width / fromSize.height)
                
            } else { // otherwise the source size is smaller in all directions.  Scale on width

                scaleSize.width = round(toSize.width)
                
                scaleSize.height = round(scaleSize.width * fromSize.height / fromSize.width)
                
                if scaleSize.height > toSize.height { // but if the new height is larger than the destination then scale height
                    
                    scaleSize.height = round(toSize.height)
                    
                    scaleSize.width = round(scaleSize.height * fromSize.width / fromSize.height)
                }
                
            }
            
        } else {   // else height is the shorter dimension

            if fromSize.height >= toSize.height {  // then give priority to height if it is larger than destination height
                
                scaleSize.height = round(toSize.height);
                
                scaleSize.width = round(scaleSize.height * fromSize.width / fromSize.height);
                
            } else if fromSize.width >= toSize.width {   // give priority to width if it is larger than the destination width
                
                scaleSize.width = round(toSize.width);
                
                scaleSize.height = round(scaleSize.width * fromSize.height / fromSize.width);
                
            } else {   // otherwise the source size is smaller in all directions.  Scale on width

                scaleSize.width = round(toSize.width);
                
                scaleSize.height = round(scaleSize.width * fromSize.height / fromSize.width);
                
                if (scaleSize.height > toSize.height) { // but if the new height is larger than the destination then scale height
                    
                    scaleSize.height = round(toSize.height);
                    
                    scaleSize.width = round(scaleSize.height * fromSize.width / fromSize.height);
                }
                
            }
        }
        
        
        return scaleSize
    }
    
    
    /**
    Returns an UIImage scaled to the input dimensions. Oftentimes the underlining CGImage does not match the orientation of the UIImage. This routing scales the UIImage dimensions not the CGImage's, and so it swaps the height and width of the scale size when it detects the UIImage is oriented differently.
     
    - parameter scaleSize the dimensions to scale the bitmap to.

    - returns: A reference to a uimage created from the scaled bitmap
    */

    func scaleBitmapToSize(_ scaleSize:CGSize) -> UIImage {
        

        /* round the size of the underlying CGImage and the input size.
        */
        var scaleSize = CGSize(width: round(scaleSize.width), height: round(scaleSize.height))
        
        /* if the underlying CGImage is oriented differently than the UIImage then swap the width and height of the scale size. This method assumes the size passed is a request on the UIImage's orientation.
        */
        if imageOrientation == UIImageOrientation.left || imageOrientation == UIImageOrientation.right {
            
            scaleSize = CGSize(width: round(scaleSize.height), height: round(scaleSize.width))
        
        }
        
        let context = CGContext(data: nil, width: Int(scaleSize.width), height: Int(scaleSize.height), bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0, space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo.rawValue)
        
        var returnImg = UIImage(cgImage:cgImage!)
        
        if context != nil {
            
            context!.draw(cgImage!, in: CGRect(x: 0, y: 0, width: scaleSize.width, height: scaleSize.height))
            
            /* realize the CGImage from the context.
            */
            let imgRef = context!.makeImage()
            
            /* realize the CGImage into a UIImage.
            */
            returnImg = UIImage(cgImage: imgRef!)
            
        } else {
            
            /* context creation failed, so return a copy of the image, and log the error.
            */
            NSLog ("NULL Bitmap Context in scaleBitmapToSize")
            
        }
        
        return returnImg
        
    }
    
     /**
     Scales the cropRectangle from the source dimensions to the destination dimensions of the underlying image.
     
     - parameter cropRect: Crop Rectangle
     - parameter fromRect: Rectangle of the source image. Crop rectangle is with respect to this rectangle.
     - parameter toRect:   Rectangle of the desitination image.
     
     - returns: A rectangle scaled from the source to the destination dimensions.
     */
    func transposeCropRect(_ cropRect:CGRect, fromBound fromRect: CGRect, toBound toRect: CGRect) -> CGRect {
        
        
        let scale = toRect.size.width / fromRect.size.width
        
        return CGRect(x: round(cropRect.origin.x * scale), y: round(cropRect.origin.y*scale), width: round(cropRect.size.width*scale), height: round(cropRect.size.height*scale))

    }
    
    
    /**
    transposes the origin of the crop rectangle to match the orientation of the underlying CGImage. For some orientations, the height and width are swaped.
    
    - parameter cropRect:    Rectangle of the region to crop
    - parameter dimension:   Size and Width of the source image
    - parameter orientation: Orientation of the source image
    
    - returns: A rectangle recalculated to orient with the source image.
    */
    func transposeCropRect(_ cropRect:CGRect, inDimension dimension:CGSize, forOrientation orientation: UIImageOrientation) -> CGRect {
        
        var transposedRect = cropRect
        
        switch (orientation) {
            
        case UIImageOrientation.left:
            transposedRect.origin.x = dimension.height - (cropRect.size.height + cropRect.origin.y)
            transposedRect.origin.y = cropRect.origin.x
            transposedRect.size = CGSize(width: cropRect.size.height, height: cropRect.size.width)
            
        case UIImageOrientation.right:
            transposedRect.origin.x = cropRect.origin.y
            transposedRect.origin.y = dimension.width - (cropRect.size.width + cropRect.origin.x)
            transposedRect.size = CGSize(width: cropRect.size.height, height: cropRect.size.width)

        case UIImageOrientation.down:
            transposedRect.origin.x = dimension.width - (cropRect.size.width + cropRect.origin.x)
            transposedRect.origin.y = dimension.height - (cropRect.size.height + cropRect.origin.y)

        case UIImageOrientation.downMirrored:
            transposedRect.origin.x = cropRect.origin.x
            transposedRect.origin.y = dimension.height - (cropRect.size.height + cropRect.origin.y)

        case UIImageOrientation.leftMirrored:
            transposedRect.origin.x = cropRect.origin.y
            transposedRect.origin.y = cropRect.origin.x
            transposedRect.size = CGSize(width: cropRect.size.height, height: cropRect.size.width)

        case UIImageOrientation.rightMirrored:
            transposedRect.origin.x = dimension.height - (cropRect.size.height + cropRect.origin.y)
            transposedRect.origin.y = dimension.width - (cropRect.size.width + cropRect.origin.x)
            transposedRect.size = CGSize(width: cropRect.size.height, height: cropRect.size.width)

        case UIImageOrientation.upMirrored:
            transposedRect.origin.x = dimension.width - (cropRect.size.width + cropRect.origin.x)
            transposedRect.origin.y = cropRect.origin.y
           
        case UIImageOrientation.up:
            break


        }
        
        return transposedRect
    }
    

     /**
     Returns a new UIImage cut from the cropArea of the underlying image.  It first scales the underlying image to the scale size before cutting the crop area from it. The returned CGImage is in the dimensions of the cropArea and it is oriented the same as the underlying CGImage as is the imageOrientation.

     
     - parameter cropRect:  The rectangular area over the image to crop.
     - parameter frameSize: The view dimensions of the image
     
     - returns: A UIImage cut from the image having the crop rect dimensions and origin.
     */
    public func cropRectangle(_ cropRect: CGRect, inFrame frameSize: CGSize) -> UIImage {
        
        
        let rndFrameSize = CGSize(width: round(frameSize.width), height: round(frameSize.height))
        
        /* resize the image to match the zoomed content size
        */
        let img = scaleBitmapToSize(rndFrameSize)
        
        /* crop the resized image to the crop rectangel.
        */
        let cropCGImage = img.cgImage!.cropping(to: transposeCropRect(cropRect, inDimension: rndFrameSize, forOrientation: imageOrientation))
        
        let croppedImg = UIImage(cgImage: cropCGImage!, scale: 1.0, orientation: imageOrientation)
        
        return croppedImg
        
    }
}



