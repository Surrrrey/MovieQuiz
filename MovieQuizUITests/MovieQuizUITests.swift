//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Сергей on 04.07.2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    // MARK: - Lifecycle

    override func setUpWithError() throws {
        try super .setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super .tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    // MARK: - Test Methods
    
    func testYesButton() {
        sleep(5)
        let firstPosterData = app.images["Poster"].screenshot().pngRepresentation

        app.buttons["Yes"].tap()
        
        sleep(5)
        let secondPosterData = app.images["Poster"].screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]

        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertFalse(firstPosterData == secondPosterData)
    }
    
    func testNoButton() {
        sleep(5)
        let firstPosterData = app.images["Poster"].screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        sleep(5)
        let secondPosterData = app.images["Poster"].screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertEqual(indexLabel.label, "2/10")
        XCTAssertFalse(firstPosterData == secondPosterData)
    }
    
    func testResultAlert() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
        
    }
    
    func testAlertButton() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()
        
        sleep(3)
        let index = app.staticTexts["Index"]
        XCTAssertTrue(index.label == "1/10")
        XCTAssertFalse(alert.exists)
    }
}
