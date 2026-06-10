//
//  ALP_MAD_26UITests.swift
//  ALP-MAD-26UITests
//
//  Created by student on 28/05/26.
//

import XCTest

final class ALP_MAD_26UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // Reset onboarding state before every UI test so the app always
        // starts from HardwareOnboardingView, regardless of prior runs.
        app.launchArguments = ["-hasCompletedOnboarding", "false"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding: Full Happy-Path Flow

    @MainActor
    func testOnboardingFormSubmissionFlow() throws {
        // 1. Verify the onboarding screen header is visible
        //    FIX: corrected text to match the actual label in HardwareOnboardingView
        let onboardingTitle = app.staticTexts["Let's calibrate your tracking."]
        XCTAssertTrue(
            onboardingTitle.waitForExistence(timeout: 3.0),
            "The onboarding screen subtitle should be visible."
        )

        // Also assert the main welcome heading
        let welcomeTitle = app.staticTexts["Welcome to DropWatch"]
        XCTAssertTrue(welcomeTitle.exists, "The 'Welcome to DropWatch' heading should be visible.")

        // 2. Find and interact with the Username TextField
        let nameTextField = app.textFields["Enter your name"]
        XCTAssertTrue(nameTextField.exists, "The name text field must be on screen.")
        nameTextField.tap()
        nameTextField.typeText("Alex")

        // 3. Select the 'Standard Showerhead' configuration card
        let standardShowerheadButton = app.buttons["Standard Showerhead"]
        XCTAssertTrue(standardShowerheadButton.exists, "The Standard Showerhead card must exist.")
        standardShowerheadButton.tap()

        // 4. Verify the Get Started button is enabled after valid input
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists, "The 'Get Started' button must exist.")
        XCTAssertTrue(getStartedButton.isEnabled, "The 'Get Started' button must be enabled once the form is valid.")
        getStartedButton.tap()

        // 5. Verify navigation to DashboardView
        let dashboardTitle = app.staticTexts["DropWatch"]
        XCTAssertTrue(
            dashboardTitle.waitForExistence(timeout: 3.0),
            "Should navigate into DashboardView after completing onboarding."
        )
    }

    // MARK: - Onboarding: Get Started disabled when form is incomplete

    @MainActor
    func testGetStartedButtonDisabledWhenFormIsEmpty() throws {
        // Without filling anything, Get Started should be disabled
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists, "The 'Get Started' button must exist.")
        XCTAssertFalse(getStartedButton.isEnabled, "The 'Get Started' button must be disabled when the form is empty.")
    }

    @MainActor
    func testGetStartedButtonDisabledWithNameButNoShowerhead() throws {
        // Name filled but no showerhead selected — button should stay disabled
        let nameTextField = app.textFields["Enter your name"]
        nameTextField.tap()
        nameTextField.typeText("Alex")

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertFalse(
            getStartedButton.isEnabled,
            "The 'Get Started' button must remain disabled until a showerhead is also selected."
        )
    }

    @MainActor
    func testGetStartedButtonDisabledWithShowerheadButNoName() throws {
        // Showerhead selected but no name — button should stay disabled
        let standardShowerheadButton = app.buttons["Standard Showerhead"]
        XCTAssertTrue(standardShowerheadButton.exists)
        standardShowerheadButton.tap()

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertFalse(
            getStartedButton.isEnabled,
            "The 'Get Started' button must remain disabled until a name is also provided."
        )
    }

    // MARK: - Onboarding: All three showerhead options are selectable

    @MainActor
    func testAllShowerheadOptionsArePresent() throws {
        XCTAssertTrue(app.buttons["Eco Showerhead"].exists, "Eco Showerhead card must be visible.")
        XCTAssertTrue(app.buttons["Standard Showerhead"].exists, "Standard Showerhead card must be visible.")
        XCTAssertTrue(app.buttons["Rainfall Showerhead"].exists, "Rainfall Showerhead card must be visible.")
    }

    @MainActor
    func testEcoShowerheadSelectionEnablesSubmit() throws {
        let nameTextField = app.textFields["Enter your name"]
        nameTextField.tap()
        nameTextField.typeText("Alex")

        app.buttons["Eco Showerhead"].tap()

        XCTAssertTrue(
            app.buttons["Get Started"].isEnabled,
            "Form should be valid after entering a name and selecting Eco Showerhead."
        )
    }

    @MainActor
    func testRainfallShowerheadSelectionEnablesSubmit() throws {
        let nameTextField = app.textFields["Enter your name"]
        nameTextField.tap()
        nameTextField.typeText("Alex")

        app.buttons["Rainfall Showerhead"].tap()

        XCTAssertTrue(
            app.buttons["Get Started"].isEnabled,
            "Form should be valid after entering a name and selecting Rainfall Showerhead."
        )
    }

    // MARK: - Onboarding: Whitespace-only name should not enable the form

    @MainActor
    func testWhitespaceOnlyNameDoesNotEnableSubmit() throws {
        let nameTextField = app.textFields["Enter your name"]
        nameTextField.tap()
        nameTextField.typeText("   ")

        app.buttons["Standard Showerhead"].tap()

        XCTAssertFalse(
            app.buttons["Get Started"].isEnabled,
            "Whitespace-only name should not satisfy form validation."
        )
    }

    // MARK: - Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
