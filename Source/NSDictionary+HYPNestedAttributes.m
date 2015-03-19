#import "NSDictionary+HYPNestedAttributes.h"

#import "HYPParsedRelationship.h"

#import "NSString+HYPRelationshipParser.h"

static NSString * const HYPNestedAttributesRailsKey = @"_attributes";

@implementation NSDictionary (HYPNestedAttributes)

- (NSDictionary *)hyp_railsNestedAttributes
{
    NSMutableDictionary *parsedIndexes = [NSMutableDictionary new];
    NSMutableArray *relationIndexes = [NSMutableArray new];

    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
        HYPParsedRelationship *parsed = [key hyp_parseRelationship];
        if (parsed.toMany) {
            NSString *indexString = [parsed.index stringValue];

            __block NSMutableDictionary *foundDictionary;
            __block BOOL found = NO;
            for (NSDictionary *currentChildDictionary in relationIndexes) {
                NSString *currentIndexString = currentChildDictionary.allKeys.firstObject;
                if ([currentIndexString isEqualToString:indexString]) {
                    foundDictionary = [currentChildDictionary[indexString] mutableCopy];
                    found = YES;
                }
            }

            if (!foundDictionary) {
                foundDictionary = [NSMutableDictionary new];
            }

            NSString *attributeKey = [self valueForKey:key];
            foundDictionary[parsed.attribute] = attributeKey;

            NSDictionary *childDictionary = @{indexString : foundDictionary};
            if (found) {
                [relationIndexes replaceObjectAtIndex:[parsed.index integerValue] withObject:childDictionary];
            } else {
                [relationIndexes addObject:childDictionary];
            }

            NSString *attributesKey = [NSString stringWithFormat:@"%@%@", parsed.relationship, HYPNestedAttributesRailsKey];
            parsedIndexes[attributesKey] = relationIndexes;
        } else {
            NSString *attributeKey = [self valueForKey:key];
            parsedIndexes[parsed.attribute] = attributeKey;
        }
    }

    return parsedIndexes;
}

- (NSDictionary *)hyp_JSONNestedAttributes
{
    NSMutableDictionary *parsedIndexes = [NSMutableDictionary new];
    NSMutableArray *relationIndexes = [NSMutableArray new];

    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
        HYPParsedRelationship *parsed = [key hyp_parseRelationship];
        if (parsed.toMany) {
            __block NSMutableDictionary *foundDictionary;
            __block BOOL found = NO;
            [relationIndexes enumerateObjectsUsingBlock:^(NSDictionary *currentChildDictionary, NSUInteger idx, BOOL *stop) {
                if ([parsed.index integerValue] == idx) {
                    foundDictionary = [currentChildDictionary mutableCopy];
                    found = YES;
                }
            }];

            if (!foundDictionary) {
                foundDictionary = [NSMutableDictionary new];
            }

            NSString *attributeKey = [self valueForKey:key];
            foundDictionary[parsed.attribute] = attributeKey;

            if (found) {
                [relationIndexes replaceObjectAtIndex:[parsed.index integerValue] withObject:foundDictionary];
            } else {
                [relationIndexes addObject:foundDictionary];
            }

            parsedIndexes[parsed.relationship] = relationIndexes;
        } else {
            NSString *attributeKey = [self valueForKey:key];
            parsedIndexes[parsed.attribute] = attributeKey;
        }
    }

    return parsedIndexes;
}

@end
