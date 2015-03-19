@import Foundation;
@import XCTest;

#import "NSDictionary+HYPNestedAttributes.h"

@interface PodTests : XCTestCase

@end

@implementation PodTests

- (void)testJSONNestedAttributesA
{
    NSDictionary *dictionary = @{@"first_name" : @"Chris",
                                 @"contacts[0].name" : @"Tim",
                                 @"contacts[0].phone_number" : @"444444",
                                 @"contacts[1].name" : @"Johannes",
                                 @"contacts[1].phone_number" : @"555555"};

    NSDictionary *contactFirst = @{@"name" : @"Tim",
                                   @"phone_number" : @"444444"};

    NSDictionary *contactSecond = @{@"name" : @"Johannes",
                                    @"phone_number" : @"555555"};

    NSDictionary *resultDictionary = @{@"first_name" : @"Chris",
                                       @"contacts" : @[contactFirst, contactSecond]};

    XCTAssertEqualObjects([dictionary hyp_JSONNestedAttributes], resultDictionary);
}

- (void)testJSONNestedAttributesB
{
    NSDictionary *dictionary = @{@"contacts[0].id" : @0,
                                 @"notes[0].id" : @0};

    NSDictionary *contact = @{@"id" : @0};

    NSDictionary *note = @{@"id" : @0};

    NSDictionary *resultDictionary = @{@"contacts" : @[contact],
                                       @"notes" : @[note]};

    XCTAssertEqualObjects([dictionary hyp_JSONNestedAttributes], resultDictionary);
}

- (void)testRailsNestedAttributesA
{
    NSDictionary *dictionary = @{@"first_name" : @"Chris",
                                 @"contacts[0].name" : @"Tim",
                                 @"contacts[0].phone_number" : @"444444",
                                 @"contacts[1].name" : @"Johannes",
                                 @"contacts[1].phone_number" : @"555555"};

    NSDictionary *contactFirst = @{@"0" : @{@"name" : @"Tim",
                                            @"phone_number" : @"444444"}};

    NSDictionary *contactSecond = @{@"1" : @{@"name" : @"Johannes",
                                             @"phone_number" : @"555555"}};

    NSDictionary *resultDictionary = @{@"first_name" : @"Chris",
                                       @"contacts_attributes" : @[contactFirst, contactSecond]};

    XCTAssertEqualObjects([dictionary hyp_railsNestedAttributes], resultDictionary);
}

- (void)testRailsNestedAttributesB
{
    NSDictionary *dictionary = @{@"contacts[0].id" : @0,
                                 @"notes[0].id" : @0};

    NSDictionary *contact = @{@"0" : @{@"id" : @0}};

    NSDictionary *note = @{@"0" : @{@"id" : @0}};

    NSDictionary *resultDictionary = @{@"contacts_attributes" : @[contact],
                                       @"notes_attributes" : @[note]};

    XCTAssertEqualObjects([dictionary hyp_railsNestedAttributes], resultDictionary);
}

@end
