#import <XCTest/XCTest.h>

@interface MaskPadUITests : XCTestCase
@end

@implementation MaskPadUITests

- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
}

- (void)pauseForLayout {
    XCTestExpectation* expectation = [self expectationWithDescription:@"layout settled"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [expectation fulfill];
                   });
    [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (XCUIApplication*)launchEditorResettingLayout:(BOOL)reset {
    XCUIApplication* app = [[XCUIApplication alloc] init];
    NSMutableDictionary<NSString*, NSString*>* environment =
        [@{ @"MASKPAD_UI_TEST_MODE": @"editor" } mutableCopy];
    if (reset) {
        environment[@"MASKPAD_UI_TEST_RESET_LAYOUT"] = @"1";
    }
    app.launchEnvironment = environment;
    [app launch];
    XCTAssertTrue([app.buttons[@"a"] waitForExistenceWithTimeout:10.0]);
    XCTAssertTrue([app.sliders[@"touch-layout-size"] waitForExistenceWithTimeout:5.0]);
    return app;
}

- (XCUIApplication*)launchControls {
    XCUIApplication* app = [[XCUIApplication alloc] init];
    app.launchEnvironment = @{
        @"MASKPAD_UI_TEST_MODE": @"controls",
        @"MASKPAD_UI_TEST_RESET_LAYOUT": @"1",
    };
    [app launch];
    XCTAssertTrue([app.buttons[@"a"] waitForExistenceWithTimeout:10.0]);
    XCTAssertTrue([app.buttons[@"test-touch-toggle"] waitForExistenceWithTimeout:5.0]);
    return app;
}

- (void)waitForElement:(XCUIElement*)element
                 value:(NSString*)value
               timeout:(NSTimeInterval)timeout {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"value == %@", value];
    XCTestExpectation* expectation =
        [self expectationForPredicate:predicate evaluatedWithObject:element handler:nil];
    [self waitForExpectations:@[ expectation ] timeout:timeout];
}

- (void)waitForElement:(XCUIElement*)element
         valueContains:(NSString*)value
               timeout:(NSTimeInterval)timeout {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"value CONTAINS %@", value];
    XCTestExpectation* expectation =
        [self expectationForPredicate:predicate evaluatedWithObject:element handler:nil];
    [self waitForExpectations:@[ expectation ] timeout:timeout];
}

- (void)testGameplayConsumesMappedInputs {
    XCUIApplication* app = [[XCUIApplication alloc] init];
    app.launchEnvironment = @{ @"MASKPAD_UI_TEST_MODE": @"gameplay" };
    [app launch];

    XCUIElement* probe = app.otherElements[@"game-input-probe"];
    XCTAssertTrue([probe waitForExistenceWithTimeout:60.0],
                  @"The supplied game archive did not reach gameplay");

    NSArray<NSString*>* buttonIdentifiers = @[
        @"d-up", @"d-down", @"d-left", @"d-right",
        @"c-up", @"c-down", @"c-left", @"c-right",
        @"l", @"r", @"z",
    ];
    for (NSString* identifier in buttonIdentifiers) {
        XCUIElement* button = app.buttons[identifier];
        XCTAssertTrue([button waitForExistenceWithTimeout:5.0], @"Missing %@", identifier);
        [button tap];
        [self waitForElement:probe
               valueContains:[NSString stringWithFormat:@"%@=1/1/0", identifier]
                     timeout:3.0];
    }

    XCUIElement* zButton = app.buttons[@"z"];
    [zButton pressForDuration:0.75];
    [self waitForElement:probe valueContains:@"z=2/1/1" timeout:3.0];
    [zButton tap];
    [self waitForElement:probe valueContains:@"z=2/2/0" timeout:3.0];

    // Let SDL pause Metal presentation before XCTest tears down the app.
    // Abrupt teardown with an outstanding drawable can create a Simulator-only
    // CAMetalDrawable crash report after every gameplay assertion has passed.
    [XCUIDevice.sharedDevice pressButton:XCUIDeviceButtonHome];
    [NSThread sleepForTimeInterval:1.0];
    [app terminate];
}

- (void)testControlPressReleaseToggleAndLifecycleCancellation {
    XCUIApplication* app = [self launchControls];
    NSArray<NSString*>* buttonIdentifiers = @[
        @"a", @"b", @"l", @"z", @"r", @"start",
        @"d-up", @"d-down", @"d-left", @"d-right",
        @"c-up", @"c-down", @"c-left", @"c-right",
    ];
    for (NSString* identifier in buttonIdentifiers) {
        XCUIElement* button = app.buttons[identifier];
        XCTAssertTrue([button waitForExistenceWithTimeout:5.0], @"Missing %@", identifier);
        [button tap];
        [self waitForElement:button
                       value:@"down=1;up=1;pressed=0;latched=0"
                     timeout:2.0];
    }

    XCUIElement* stick = app.otherElements[@"stick"];
    XCTAssertTrue([stick waitForExistenceWithTimeout:5.0]);
    NSArray<NSValue*>* offsets = @[
        [NSValue valueWithCGVector:CGVectorMake(0.5, 0.02)],
        [NSValue valueWithCGVector:CGVectorMake(0.5, 0.98)],
        [NSValue valueWithCGVector:CGVectorMake(0.02, 0.5)],
        [NSValue valueWithCGVector:CGVectorMake(0.98, 0.5)],
    ];
    NSArray<NSString*>* stickValues = @[
        @"up=1/1;down=0/0;left=0/0;right=0/0",
        @"up=1/1;down=1/1;left=0/0;right=0/0",
        @"up=1/1;down=1/1;left=1/1;right=0/0",
        @"up=1/1;down=1/1;left=1/1;right=1/1",
    ];
    for (NSUInteger index = 0; index < offsets.count; index++) {
        XCUICoordinate* destination =
            [stick coordinateWithNormalizedOffset:offsets[index].CGVectorValue];
        [[stick coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)]
            pressForDuration:0.1
            thenDragToCoordinate:destination];
        [self waitForElement:stick value:stickValues[index] timeout:2.0];
    }

    XCUIElement* zButton = app.buttons[@"z"];
    [zButton pressForDuration:0.75];
    [self waitForElement:zButton
                   value:@"down=2;up=1;pressed=1;latched=1"
                 timeout:2.0];
    [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];
    [app activate];
    XCTAssertTrue([zButton waitForExistenceWithTimeout:5.0]);
    [self waitForElement:zButton
                   value:@"down=2;up=2;pressed=0;latched=0"
                 timeout:2.0];

    XCUIElement* toggle = app.buttons[@"test-touch-toggle"];
    [toggle tap];
    XCTAssertTrue([app.buttons[@"a"] waitForNonExistenceWithTimeout:5.0]);
    [self waitForElement:toggle value:@"disabled" timeout:2.0];
    [toggle tap];
    XCTAssertTrue([app.buttons[@"a"] waitForExistenceWithTimeout:5.0]);
    [self waitForElement:toggle value:@"enabled" timeout:2.0];
}

- (void)testMoveResizeClampProtectionResetAndPersistence {
    XCUIApplication* app = [self launchEditorResettingLayout:YES];
    XCUIElement* buttonA = app.buttons[@"a"];
    XCUIElement* slider = app.sliders[@"touch-layout-size"];
    CGRect defaultFrame = buttonA.frame;

    [slider adjustToNormalizedSliderPosition:1.0];
    [self pauseForLayout];
    XCTAssertGreaterThan(buttonA.frame.size.width, defaultFrame.size.width * 1.42);

    [slider adjustToNormalizedSliderPosition:0.0];
    [self pauseForLayout];
    XCTAssertLessThan(buttonA.frame.size.width, defaultFrame.size.width * 0.76);

    [slider adjustToNormalizedSliderPosition:0.625];
    [self pauseForLayout];
    CGFloat expectedPersistedWidth = defaultFrame.size.width * 1.2;
    XCTAssertEqualWithAccuracy(buttonA.frame.size.width, expectedPersistedWidth, 3.0);

    XCUICoordinate* destination =
        [app coordinateWithNormalizedOffset:CGVectorMake(0.72, 0.72)];
    [[buttonA coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)]
        pressForDuration:0.15
        thenDragToCoordinate:destination];
    [self pauseForLayout];
    CGRect movedFrame = buttonA.frame;
    XCTAssertGreaterThan(fabs(CGRectGetMidX(movedFrame) - CGRectGetMidX(defaultFrame)), 20.0);

    [app.buttons[@"touch-layout-done"] tap];
    XCUIElement* nativeHudProbe = app.otherElements[@"native-hud-a-probe"];
    XCTAssertTrue([nativeHudProbe waitForExistenceWithTimeout:5.0]);
    XCTAssertEqualWithAccuracy(
        CGRectGetMidX(nativeHudProbe.frame), CGRectGetMidX(movedFrame), 2.0);
    XCTAssertEqualWithAccuracy(
        CGRectGetMidY(nativeHudProbe.frame), CGRectGetMidY(movedFrame), 2.0);
    XCTAssertEqualWithAccuracy(
        CGRectGetWidth(nativeHudProbe.frame), CGRectGetWidth(movedFrame), 2.0);
    [app terminate];

    app = [self launchEditorResettingLayout:NO];
    buttonA = app.buttons[@"a"];
    XCTAssertEqualWithAccuracy(buttonA.frame.size.width, movedFrame.size.width, 3.0);
    XCTAssertEqualWithAccuracy(CGRectGetMidX(buttonA.frame), CGRectGetMidX(movedFrame), 6.0);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(buttonA.frame), CGRectGetMidY(movedFrame), 6.0);

    XCUICoordinate* outside =
        [app coordinateWithNormalizedOffset:CGVectorMake(1.08, 1.08)];
    [[buttonA coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)]
        pressForDuration:0.15
        thenDragToCoordinate:outside];
    [self pauseForLayout];
    CGRect clampedFrame = buttonA.frame;
    XCTAssertLessThanOrEqual(CGRectGetMaxX(clampedFrame), CGRectGetMaxX(app.frame) + 1.0);
    XCTAssertLessThanOrEqual(CGRectGetMaxY(clampedFrame), CGRectGetMaxY(app.frame) + 1.0);

    XCUIElement* stick = app.otherElements[@"stick"];
    XCTAssertTrue([stick waitForExistenceWithTimeout:5.0]);
    [stick tap];
    XCUIElement* visibility = app.buttons[@"touch-layout-visibility"];
    XCTAssertTrue(visibility.exists);
    XCTAssertFalse(visibility.enabled);

    [app.buttons[@"touch-layout-reset"] tap];
    [self pauseForLayout];
    buttonA = app.buttons[@"a"];
    XCTAssertEqualWithAccuracy(buttonA.frame.size.width, defaultFrame.size.width, 3.0);
    [app.buttons[@"touch-layout-done"] tap];
}

@end
