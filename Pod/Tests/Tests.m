@import Foundation;
@import XCTest;

#import "NSDictionary+HYPNestedAttributes.h"

@interface PodTests : XCTestCase

@end

@implementation PodTests

- (void)testNestifyA
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

    XCTAssertEqualObjects([dictionary hyp_nestify], resultDictionary);
}

- (void)testNestifyB
{
    NSDictionary *dictionary = @{@"contacts[0].id" : @0,
                                 @"notes[0].id" : @0};

    NSDictionary *contact = @{@"0" : @{@"id" : @0}};

    NSDictionary *note = @{@"0" : @{@"id" : @0}};

    NSDictionary *resultDictionary = @{@"contacts_attributes" : @[contact],
                                       @"notes_attributes" : @[note]};

    XCTAssertEqualObjects([dictionary hyp_nestify], resultDictionary);
}

@end
