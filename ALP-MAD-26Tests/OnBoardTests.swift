//
//  OnBoardTests.swift
//  ALP-MAD-26Tests
//
//  Created by student on 03/06/26.
//

import XCTest
@testable import ALP_MAD_26

final class OnBoardTests: XCTestCase {
    
    // System Under Test
    var sut: OnboardingViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = OnboardingViewModel()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    
    // MARK: - 1. Initial State
    
    func test_initialState_userNameIsEmpty() {
        XCTAssertEqual(sut.userName, "")
    }
    
    func test_initialState_selectedShowerheadIsNil() {
        XCTAssertNil(sut.selectedShowerhead)
    }
    
    func test_initialState_heaterTypeDefaultsToElectric() {
        XCTAssertEqual(sut.heaterType, .electric)
    }
    
    func test_initialState_hasWaterHeaterIsTrue() {
        // Because heaterType defaults to .electric, the toggle should start ON
        XCTAssertTrue(sut.hasWaterHeater)
    }
    
    func test_initialState_formIsInvalid() {
        // No name, no showerhead — form must not be submittable
        XCTAssertFalse(sut.isFormValid)
    }
    
    
    // MARK: - 2. Form Validation
    
    func test_formValidation_validNameAndShowerhead_isValid() {
        sut.userName = "Budi"
        sut.selectedShowerhead = .standard
        XCTAssertTrue(sut.isFormValid)
    }
    
    func test_formValidation_emptyName_isInvalid() {
        sut.userName = ""
        sut.selectedShowerhead = .standard
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_formValidation_whitespaceOnlyName_isInvalid() {
        // Spaces alone must not count as a valid name
        sut.userName = "     "
        sut.selectedShowerhead = .eco
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_formValidation_nameWithPaddingSpaces_isValid() {
        // Leading/trailing spaces are stripped — inner characters count
        sut.userName = "  Ani  "
        sut.selectedShowerhead = .eco
        XCTAssertTrue(sut.isFormValid)
    }
    
    func test_formValidation_noShowerheadSelected_isInvalid() {
        sut.userName = "Budi"
        sut.selectedShowerhead = nil
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_formValidation_bothEmpty_isInvalid() {
        sut.userName = ""
        sut.selectedShowerhead = nil
        XCTAssertFalse(sut.isFormValid)
    }
    
    func test_formValidation_allThreeShowerheadChoices_areAccepted() {
        sut.userName = "Dewi"
        for type in OnboardingViewModel.ShowerheadType.allCases {
            sut.selectedShowerhead = type
            XCTAssertTrue(sut.isFormValid, "\(type) should produce a valid form")
        }
    }
    
    
    // MARK: - 3. hasWaterHeater Toggle Logic
    
    func test_hasWaterHeater_heaterTypeNone_returnsFalse() {
        sut.heaterType = .none
        XCTAssertFalse(sut.hasWaterHeater)
    }
    
    func test_hasWaterHeater_heaterTypeElectric_returnsTrue() {
        sut.heaterType = .electric
        XCTAssertTrue(sut.hasWaterHeater)
    }
    
    func test_hasWaterHeater_heaterTypeLPG_returnsTrue() {
        sut.heaterType = .lpg
        XCTAssertTrue(sut.hasWaterHeater)
    }
    
    func test_hasWaterHeaterSetter_setFalse_resetsHeaterTypeToNone() {
        sut.heaterType = .lpg
        sut.hasWaterHeater = false
        XCTAssertEqual(sut.heaterType, .none)
    }
    
    func test_hasWaterHeaterSetter_setTrue_defaultsHeaterTypeToElectric() {
        // When re-enabling from .none, Electric should be the safe default
        sut.heaterType = .none
        sut.hasWaterHeater = true
        XCTAssertEqual(sut.heaterType, .electric)
    }
    
    func test_hasWaterHeaterSetter_toggleOffThenOn_heaterTypeIsElectric() {
        sut.heaterType = .lpg
        sut.hasWaterHeater = false
        sut.hasWaterHeater = true
        // After toggle cycle, must land on Electric, not LPG
        XCTAssertEqual(sut.heaterType, .electric)
    }
    
    
    // MARK: - 4. ShowerheadType Enum
    
    func test_showerheadType_eco_hasCorrectFlowRate() {
        XCTAssertEqual(OnboardingViewModel.ShowerheadType.eco.flowRateLPM, 5.5)
    }
    
    func test_showerheadType_standard_hasCorrectFlowRate() {
        XCTAssertEqual(OnboardingViewModel.ShowerheadType.standard.flowRateLPM, 9.0)
    }
    
    func test_showerheadType_rainfall_hasCorrectFlowRate() {
        XCTAssertEqual(OnboardingViewModel.ShowerheadType.rainfall.flowRateLPM, 12.0)
    }
    
    func test_showerheadType_eco_hasCorrectDisplayName() {
        XCTAssertEqual(OnboardingViewModel.ShowerheadType.eco.displayName, "Eco Showerhead")
    }
    
    func test_showerheadType_standard_hasCorrectDisplayName() {
        XCTAssertEqual(OnboardingViewModel.ShowerheadType.standard.displayName, "Standard Showerhead")
    }
    
    func test_showerheadType_rainfall_hasCorrectDisplayName() {
        XCTAssertEqual(OnboardingViewModel.ShowerheadType.rainfall.displayName, "Rainfall / High-Flow")
    }
    
    func test_showerheadType_hasExactlyThreeCases() {
        XCTAssertEqual(OnboardingViewModel.ShowerheadType.allCases.count, 3)
    }
    
    func test_showerheadType_allFlowRatesArePositive() {
        for type in OnboardingViewModel.ShowerheadType.allCases {
            XCTAssertGreaterThan(type.flowRateLPM, 0, "\(type) must have a positive flow rate")
        }
    }
    
    func test_showerheadType_flowRatesAreInAscendingOrder() {
        // Eco must be lowest, rainfall highest — validates the physical hierarchy
        let eco      = OnboardingViewModel.ShowerheadType.eco.flowRateLPM
        let standard = OnboardingViewModel.ShowerheadType.standard.flowRateLPM
        let rainfall = OnboardingViewModel.ShowerheadType.rainfall.flowRateLPM
        XCTAssertLessThan(eco, standard)
        XCTAssertLessThan(standard, rainfall)
    }
    
    
    // MARK: - 5. HeaterType Enum
    
    func test_heaterType_none_rawValue() {
        XCTAssertEqual(OnboardingViewModel.HeaterType.none.rawValue, "None")
    }
    
    func test_heaterType_electric_rawValue() {
        XCTAssertEqual(OnboardingViewModel.HeaterType.electric.rawValue, "Electric")
    }
    
    func test_heaterType_lpg_rawValue() {
        XCTAssertEqual(OnboardingViewModel.HeaterType.lpg.rawValue, "LPG")
    }
    
    func test_heaterType_hasExactlyThreeCases() {
        XCTAssertEqual(OnboardingViewModel.HeaterType.allCases.count, 3)
    }
    
    
    // MARK: - 6. HardwareProfile Mapping (ViewModel → Model)
    // Simulates the profile object that onboarding would persist via SwiftData.
    
    func test_hardwareProfileMapping_electricHeater_isCorrect() {
        sut.userName = "Budi"
        sut.selectedShowerhead = .standard
        sut.heaterType = .electric
        
        let profile = HardwareProfile(
            userName: sut.userName,
            flowRateLPM: sut.selectedShowerhead!.flowRateLPM,
            hasWaterHeater: sut.hasWaterHeater,
            heaterType: sut.heaterType.rawValue
        )
        
        XCTAssertEqual(profile.userName, "Budi")
        XCTAssertEqual(profile.flowRateLPM, 9.0)
        XCTAssertTrue(profile.hasWaterHeater)
        XCTAssertEqual(profile.heaterType, "Electric")
    }
    
    func test_hardwareProfileMapping_lpgHeater_isCorrect() {
        sut.userName = "Dewi"
        sut.selectedShowerhead = .rainfall
        sut.heaterType = .lpg
        
        let profile = HardwareProfile(
            userName: sut.userName,
            flowRateLPM: sut.selectedShowerhead!.flowRateLPM,
            hasWaterHeater: sut.hasWaterHeater,
            heaterType: sut.heaterType.rawValue
        )
        
        XCTAssertEqual(profile.userName, "Dewi")
        XCTAssertEqual(profile.flowRateLPM, 12.0)
        XCTAssertTrue(profile.hasWaterHeater)
        XCTAssertEqual(profile.heaterType, "LPG")
    }
    
    func test_hardwareProfileMapping_noHeater_isCorrect() {
        sut.userName = "Ani"
        sut.selectedShowerhead = .eco
        sut.hasWaterHeater = false // This sets heaterType to .none
        
        let profile = HardwareProfile(
            userName: sut.userName,
            flowRateLPM: sut.selectedShowerhead!.flowRateLPM,
            hasWaterHeater: sut.hasWaterHeater,
            heaterType: sut.heaterType.rawValue
        )
        
        XCTAssertEqual(profile.userName, "Ani")
        XCTAssertEqual(profile.flowRateLPM, 5.5)
        XCTAssertFalse(profile.hasWaterHeater)
        XCTAssertEqual(profile.heaterType, "None")
    }
    
    func test_hardwareProfileMapping_flowRateMatchesSelectedShowerhead() {
        // Verify every showerhead type maps its flow rate to the profile correctly
        let cases: [(OnboardingViewModel.ShowerheadType, Double)] = [
            (.eco, 5.5),
            (.standard, 9.0),
            (.rainfall, 12.0)
        ]
        
        sut.userName = "TestUser"
        for (type, expectedRate) in cases {
            sut.selectedShowerhead = type
            let profile = HardwareProfile(
                userName: sut.userName,
                flowRateLPM: sut.selectedShowerhead!.flowRateLPM,
                hasWaterHeater: true,
                heaterType: "Electric"
            )
            XCTAssertEqual(profile.flowRateLPM, expectedRate, "\(type) should map to \(expectedRate) LPM")
        }
    }
    
    
    // MARK: - 7. Constants Consistency
    // Ensures the ViewModel's hardcoded flow rates stay in sync with Constants.swift.
    
    func test_constants_ecoFlowRateMatchesShowerheadType() {
        XCTAssertEqual(Constants.FlowRate.eco, OnboardingViewModel.ShowerheadType.eco.flowRateLPM)
    }
    
    func test_constants_standardFlowRateMatchesShowerheadType() {
        XCTAssertEqual(Constants.FlowRate.standard, OnboardingViewModel.ShowerheadType.standard.flowRateLPM)
    }
    
    func test_constants_highFlowRateMatchesShowerheadType() {
        XCTAssertEqual(Constants.FlowRate.highFlow, OnboardingViewModel.ShowerheadType.rainfall.flowRateLPM)
    }
    
    func test_constants_temperatureDeltaIsPositive() {
        // Heating from groundwater to target must always require energy
        let delta = Constants.targetShowerTemperature - Constants.groundwaterTemperature
        XCTAssertGreaterThan(delta, 0)
    }
    
    
    // MARK: - 8. CalculationEngine — Downstream of Onboarding Data
    // These tests confirm that the profile values saved in onboarding
    // produce correct results when fed into CalculationEngine.
    
    func test_calculationEngine_waterUsed_ecoShowerhead_baselineDuration() {
        // 5.5 LPM × 10 min = 55.0 L
        let result = CalculationEngine.calculateWaterUsed(
            durationInMinutes: Constants.baselineShowerDurationMinutes,
            flowRateLPM: OnboardingViewModel.ShowerheadType.eco.flowRateLPM
        )
        XCTAssertEqual(result, 55.0, accuracy: 0.001)
    }
    
    func test_calculationEngine_waterUsed_standardShowerhead_baselineDuration() {
        // 9.0 LPM × 10 min = 90.0 L
        let result = CalculationEngine.calculateWaterUsed(
            durationInMinutes: Constants.baselineShowerDurationMinutes,
            flowRateLPM: OnboardingViewModel.ShowerheadType.standard.flowRateLPM
        )
        XCTAssertEqual(result, 90.0, accuracy: 0.001)
    }
    
    func test_calculationEngine_waterUsed_rainfallShowerhead_baselineDuration() {
        // 12.0 LPM × 10 min = 120.0 L
        let result = CalculationEngine.calculateWaterUsed(
            durationInMinutes: Constants.baselineShowerDurationMinutes,
            flowRateLPM: OnboardingViewModel.ShowerheadType.rainfall.flowRateLPM
        )
        XCTAssertEqual(result, 120.0, accuracy: 0.001)
    }
    
    func test_calculationEngine_waterUsed_zeroDuration_returnsZero() {
        let result = CalculationEngine.calculateWaterUsed(
            durationInMinutes: 0,
            flowRateLPM: OnboardingViewModel.ShowerheadType.standard.flowRateLPM
        )
        XCTAssertEqual(result, 0.0)
    }
    
    func test_calculationEngine_electricEnergy_withElectricHeater_isCorrect() {
        // 90 L × 0.015 kWh = 1.35 kWh
        let result = CalculationEngine.calculateElectricity(
            waterLiters: 90.0,
            hasHeater: true,
            heaterType: OnboardingViewModel.HeaterType.electric.rawValue
        )
        XCTAssertEqual(result, 1.35, accuracy: 0.001)
    }
    
    func test_calculationEngine_electricEnergy_withNoHeater_isZero() {
        let result = CalculationEngine.calculateElectricity(
            waterLiters: 90.0,
            hasHeater: false,
            heaterType: OnboardingViewModel.HeaterType.electric.rawValue
        )
        XCTAssertEqual(result, 0.0)
    }
    
    func test_calculationEngine_electricEnergy_withLPGHeater_isZero() {
        // Selecting LPG in onboarding must not produce an electric reading
        let result = CalculationEngine.calculateElectricity(
            waterLiters: 90.0,
            hasHeater: true,
            heaterType: OnboardingViewModel.HeaterType.lpg.rawValue
        )
        XCTAssertEqual(result, 0.0)
    }
    
    func test_calculationEngine_lpgMass_withLPGHeater_isCorrect() {
        // Q = 90 × 4.184 × 13 = 4895.28 kJ
        // kg = 4895.28 / (46000 × 0.85) ≈ 0.1253 kg
        let result = CalculationEngine.calculateLPG(
            waterLiters: 90.0,
            hasHeater: true,
            heaterType: OnboardingViewModel.HeaterType.lpg.rawValue
        )
        XCTAssertEqual(result, 0.1253, accuracy: 0.001)
    }
    
    func test_calculationEngine_lpgMass_withNoHeater_isZero() {
        let result = CalculationEngine.calculateLPG(
            waterLiters: 90.0,
            hasHeater: false,
            heaterType: OnboardingViewModel.HeaterType.lpg.rawValue
        )
        XCTAssertEqual(result, 0.0)
    }
    
    func test_calculationEngine_lpgMass_withElectricHeater_isZero() {
        // Selecting Electric in onboarding must not produce an LPG reading
        let result = CalculationEngine.calculateLPG(
            waterLiters: 90.0,
            hasHeater: true,
            heaterType: OnboardingViewModel.HeaterType.electric.rawValue
        )
        XCTAssertEqual(result, 0.0)
    }
    
    func test_calculationEngine_waterSaved_underBaseline_isPositive() {
        // 5-minute shower with standard head saves (10-5) × 9 = 45 L
        let result = CalculationEngine.calculateWaterSaved(
            baselineDurationMinutes: Constants.baselineShowerDurationMinutes, // Pass the baseline here!
            actualDurationInMinutes: 5.0,
            flowRateLPM: OnboardingViewModel.ShowerheadType.standard.flowRateLPM
        )
        XCTAssertEqual(result, 45.0, accuracy: 0.001)
    }
    func test_calculationEngine_waterSaved_equalToBaseline_isZero() {
        let result = CalculationEngine.calculateWaterSaved(
            baselineDurationMinutes: Constants.baselineShowerDurationMinutes, // Pass the baseline here!
            actualDurationInMinutes: Constants.baselineShowerDurationMinutes,
            flowRateLPM: OnboardingViewModel.ShowerheadType.standard.flowRateLPM
        )
        XCTAssertEqual(result, 0.0)
    }
    func test_calculationEngine_waterSaved_overBaseline_isZero() {
        let result = CalculationEngine.calculateWaterSaved(
            baselineDurationMinutes: Constants.baselineShowerDurationMinutes, // Pass the baseline here!
            actualDurationInMinutes: 15.0,
            flowRateLPM: OnboardingViewModel.ShowerheadType.rainfall.flowRateLPM
        )
        XCTAssertEqual(result, 0.0)
    }
}
