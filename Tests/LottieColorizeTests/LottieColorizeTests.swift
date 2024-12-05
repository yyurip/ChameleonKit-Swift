
@testable import LottieColorize
import XCTest
import SwiftUI

@available(macOS 11, *)
final class LottieColorizeTests: XCTestCase {
    private var sampleInputData: Data!
    private var sampleMapping: [String: String]!
    private var destinationURL: URL!
    
    override func setUp() {
        super.setUp()
        
        // Sample JSON input representing a Lottie file
        let sampleJSON: [String: Any] = [
            "layers": [
                [
                    "k": [0.5, 0.5, 0.5, 1.0], // Example color in RGBA
                    "otherKey": "value"
                ]
            ]
        ]
        sampleInputData = try! JSONSerialization.data(withJSONObject: sampleJSON, options: [])
        
        // Color mapping: map gray (hex #808080) to red (#FF0000)
        sampleMapping = [
            "808080": "FF0000"
        ]
        
        // Destination file URL (temporary file)
        destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("start.json")
    }
    
    override func tearDown() {
        // Cleanup temporary file if exists
        try? FileManager.default.removeItem(at: destinationURL)
        
        super.tearDown()
    }
    
    func testColorizeWithData_UpdatesColors() throws {
        // Act
        try LottieColorize.colorize(
            input: sampleInputData,
            with: sampleMapping,
            destination: destinationURL
        )
        
        // Assert
        let resultData = try Data(contentsOf: destinationURL)
        let resultJSON = try JSONSerialization.jsonObject(with: resultData) as! [String: Any]
        let layers = resultJSON["layers"] as! [[String: Any]]
        let updatedColor = layers.first?["k"] as? [Float]
        
        // Check if the color was updated to red (#FF0000 -> [1.0, 0.0, 0.0, 1.0])
        XCTAssertEqual(updatedColor, [1.0, 0.0, 0.0, 1.0])
    }
    
    func testColorizeWithURL_UpdatesColors() throws {
        // Arrange
        let inputURL = FileManager.default.temporaryDirectory.appendingPathComponent("start.json")
        try sampleInputData.write(to: inputURL)
        
        // Act
        try LottieColorize.colorize(input: inputURL, with: sampleMapping, destination: destinationURL)
        
        // Assert
        let resultData = try Data(contentsOf: destinationURL)
        let resultJSON = try JSONSerialization.jsonObject(with: resultData) as! [String: Any]
        let layers = resultJSON["layers"] as! [[String: Any]]
        let updatedColor = layers.first?["k"] as? [Float]
        
        // Check if the color was updated to red (#FF0000 -> [1.0, 0.0, 0.0, 1.0])
        XCTAssertEqual(updatedColor, [1.0, 0.0, 0.0, 1.0])
        
        // Cleanup
        try FileManager.default.removeItem(at: inputURL)
    }
    
    func testInvalidInput_ThrowsError() {
        // Arrange
        let invalidData = Data("invalid".utf8)
        
        // Act & Assert
        XCTAssertThrowsError(
            try LottieColorize.colorize(input: invalidData, with: sampleMapping, destination: destinationURL)
        ) { error in
            XCTAssertNotNil(error)
        }
    }
}
