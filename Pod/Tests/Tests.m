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
                                 @"contacts[0].phone_number" : @"3657732"};

    NSDictionary *contact = @{@"0" : @{@"name" : @"Tim",
                                       @"phone_number" : @"3657732"}};

    NSDictionary *resultDictionary = @{@"first_name" : @"Chris",
                                       @"contacts_attributes" : @[contact]};

    XCTAssertEqualObjects([dictionary hyp_nestify], resultDictionary);
}

@end
