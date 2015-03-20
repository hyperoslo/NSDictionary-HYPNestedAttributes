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

- (void)testJSONNestedAttributesC
{
    NSDictionary *dictionary = @{@"children[0].birthdate" : @"2014-03-20 13:15:26 +0000",
                                 @"children[0].name" : @"Hallo",
                                 @"contacts[0].name" : @"Hei there",
                                 @"contacts[0].phone_number" : @"7312312",
                                 @"contacts[1].name" : @"Parorent",
                                 @"contacts[1].phone_number" : @"23124421"};

    NSDictionary *children = @{@"birthdate" : @"2014-03-20 13:15:26 +0000",
                               @"name" : @"Hallo"};

    NSDictionary *contactA = @{@"name" : @"Hei there",
                               @"phone_number" : @"7312312"};

    NSDictionary *contactB = @{@"name" : @"Parorent",
                               @"phone_number" : @"23124421"};

    NSDictionary *resultDictionary = @{@"children" : @[children],
                                       @"contacts" : @[contactA, contactB]};

    XCTAssertEqualObjects([dictionary hyp_JSONNestedAttributes], resultDictionary);
}

- (void)testRailsNestedAttributesA
{
    NSDictionary *dictionary = @{@"first_name" : @"Chris",
                                 @"contacts[0].name" : @"Tim",
                                 @"contacts[0].phone_number" : @"444444",
                                 @"contacts[1].name" : @"Johannes",
                                 @"contacts[1].phone_number" : @"555555"};

    NSDictionary *contacts = @{@"0" : @{@"name" : @"Tim",
                                            @"phone_number" : @"444444"},
                                   @"1" : @{@"name" : @"Johannes",
                                            @"phone_number" : @"555555"}};

    NSDictionary *resultDictionary = @{@"first_name" : @"Chris",
                                       @"contacts_attributes" : contacts};

    XCTAssertEqualObjects([dictionary hyp_railsNestedAttributes], resultDictionary);
}

- (void)testRailsNestedAttributesB
{
    NSDictionary *dictionary = @{@"contacts[0].id" : @0,
                                 @"notes[0].id" : @0};

    NSDictionary *contact = @{@"0" : @{@"id" : @0}};
    NSDictionary *note = @{@"0" : @{@"id" : @0}};
    NSDictionary *resultDictionary = @{@"contacts_attributes" : contact,
                                       @"notes_attributes" : note};

    XCTAssertEqualObjects([dictionary hyp_railsNestedAttributes], resultDictionary);
}

- (void)testRailsNestedAttributesC
{
    NSDictionary *dictionary = @{@"children[0].birthdate" : @"2014-03-20 13:15:26 +0000",
                                 @"children[0].name" : @"Hallo",
                                 @"contacts[0].name" : @"Hei there",
                                 @"contacts[0].phone_number" : @"7312312",
                                 @"contacts[1].name" : @"Parorent",
                                 @"contacts[1].phone_number" : @"23124421"};

    NSDictionary *children = @{@"0" : @{@"birthdate" : @"2014-03-20 13:15:26 +0000",
                                        @"name" : @"Hallo"}};

    NSDictionary *contacts = @{@"0" : @{@"name" : @"Hei there",
                                        @"phone_number" : @"7312312"},
                               @"1" : @{@"name" : @"Parorent",
                                        @"phone_number" : @"23124421"}};

    NSDictionary *resultDictionary = @{@"children_attributes" : children,
                                       @"contacts_attributes" : contacts};

    XCTAssertEqualObjects([dictionary hyp_railsNestedAttributes], resultDictionary);
}

@end
