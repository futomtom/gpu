import UIKit
import GPUImage


extension UIImage {
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
    }
}




class ViewController: UIViewController {

    @IBOutlet weak var renderView: RenderView!


    var picture: PictureInput!


    @IBOutlet weak var imageView: UIImageView!


    override func viewDidLoad() {
        let testImage = UIImage(named: "640.jpg")!
        let LuminanceFliter = Luminance()
        let laplacianFilter = Laplacian()
        let image = testImage.filterWithPipeline { input, output in
            input --> LuminanceFliter --> laplacianFilter --> output
        }
        
        let cgImage = image.cgImage
        let pixelData = cgImage!.dataProvider!.data

        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
       let bytesPerRow = cgImage!.bytesPerRow
        let bytesPerPixel = cgImage!.bitsPerPixel / 8
        var position = 0
        var pixelsArray = [Float]()
        
        for _ in 0..<640 {
              for _ in 0..<480 {
                let alpha = Float(data[position + 3])
                pixelsArray.append(alpha / 255)
                position += bytesPerPixel
            }
            if position % bytesPerRow != 0 {
                position += (bytesPerRow - (position % bytesPerRow))
            }
        }
    }
}

