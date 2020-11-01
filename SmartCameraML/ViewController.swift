//
//  ViewController.swift
//  SmartCameraML
//
//  Created by Arun Jamal on 2020-10-31.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Start up the camera here
        let captureSession = AVCaptureSession() // AVCapture session is needed to create the capture session so the app can take input, in this case through the camera
        
        // .video in the AVCaptureDevice is for the back camera on an iPhone
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        // try? is used for error handling if the device doesn't have a camera
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        // Need to start the capture session so the app can take in input data
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
//        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
    }
    var testy = 0
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            // check the err
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            let labelRect = CGRect(x: 0, y: self.testy, width: 300, height: 100)

            DispatchQueue.main.async {
                let label = UILabel(frame: labelRect)
                var output = firstObservation.identifier.components(separatedBy: ",")
//                print(output [0])
                label.text = output[0]
//                print(firstObservation.identifier[0])
                label.font = UIFont(name: "Arial",size: 30.0)
                label.numberOfLines = 2
                self.view.addSubview(label)

            }
            self.testy += 30
            sleep(2)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
}

