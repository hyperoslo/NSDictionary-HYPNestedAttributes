@import Foundation;
@import XCTest;

#import "NSDictionary+HYPNestedAttributes.h"

@interface PodTests : XCTestCase

@end

@implementation PodTests

- (void)testNestify
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

@end
