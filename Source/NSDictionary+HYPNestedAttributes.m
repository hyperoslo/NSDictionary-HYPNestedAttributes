#import "NSDictionary+HYPNestedAttributes.h"

#import "HYPParsedRelationship.h"

#import "NSString+HYPRelationshipParser.h"

static NSString * const HYPNestedAttributesRailsKey = @"_attributes";

typedef NS_ENUM(NSInteger, HYPNestedAttributesType) {
    HYPJSONNestedAttributesType,
    HYPRailsNestedAttributesType
};

@implementation NSDictionary (HYPNestedAttributes)

- (NSDictionary *)hyp_JSONNestedAttributes
{
    return [self nestedAttributes:HYPJSONNestedAttributesType];
}

- (NSDictionary *)hyp_railsNestedAttributes
{
    return [self nestedAttributes:HYPRailsNestedAttributesType];
}

- (NSDictionary *)nestedAttributes:(HYPNestedAttributesType)type
{
    NSMutableDictionary *parsedIndexes = [NSMutableDictionary new];
    NSMutableArray *relationIndexes = [NSMutableArray new];

    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
        HYPParsedRelationship *parsed = [key hyp_parseRelationship];
        if (parsed.toMany) {
            if (type == HYPJSONNestedAttributesType) {
                relationIndexes = [[self JSONProcessKeyRelationIndexes:relationIndexes
                                                                parsed:parsed
                                                                   key:key] mutableCopy];
                parsedIndexes[parsed.relationship] = relationIndexes;
            } else if (type == HYPRailsNestedAttributesType) {
                relationIndexes = [[self railsProcessKeyRelationIndexes:relationIndexes parsed:parsed key:key] mutableCopy];
                NSString *attributesKey = [NSString stringWithFormat:@"%@%@", parsed.relationship, HYPNestedAttributesRailsKey];
                parsedIndexes[attributesKey] = relationIndexes;
            }
        } else {
            NSString *attributeKey = [self valueForKey:key];
            parsedIndexes[parsed.attribute] = attributeKey;
        }
    }

    return parsedIndexes;
}

- (NSArray *)railsProcessKeyRelationIndexes:(NSMutableArray *)relationIndexes parsed:(HYPParsedRelationship *)parsed key:(NSString *)key
{
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

    return relationIndexes;
}

- (NSArray *)JSONProcessKeyRelationIndexes:(NSMutableArray *)relationIndexes parsed:(HYPParsedRelationship *)parsed key:(NSString *)key
{
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

    return relationIndexes;
}

@end
