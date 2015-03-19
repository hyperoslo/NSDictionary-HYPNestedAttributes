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
    NSMutableDictionary *attributesDictionary = [NSMutableDictionary new];
    NSMutableArray *nestedAttributes = [NSMutableArray new];

    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
        HYPParsedRelationship *parsed = [key hyp_parseRelationship];
        if (parsed.toMany) {
            if (type == HYPJSONNestedAttributesType) {
                nestedAttributes = [[self JSONProcessNestedAttributes:nestedAttributes
                                                               parsed:parsed
                                                                  key:key] mutableCopy];
                attributesDictionary[parsed.relationship] = nestedAttributes;
            } else if (type == HYPRailsNestedAttributesType) {
                nestedAttributes = [[self railsProcessNestedAttributes:nestedAttributes parsed:parsed key:key] mutableCopy];
                NSString *attributesKey = [NSString stringWithFormat:@"%@%@", parsed.relationship, HYPNestedAttributesRailsKey];
                attributesDictionary[attributesKey] = nestedAttributes;
            }
        } else {
            NSString *attributeKey = [self valueForKey:key];
            attributesDictionary[parsed.attribute] = attributeKey;
        }
    }

    return attributesDictionary;
}

- (NSArray *)JSONProcessNestedAttributes:(NSArray *)nestedAttributes parsed:(HYPParsedRelationship *)parsed key:(NSString *)key
{
    NSMutableArray *processedNestedAttributes = [nestedAttributes mutableCopy];
    __block NSMutableDictionary *foundDictionary;
    __block BOOL found = NO;
    [nestedAttributes enumerateObjectsUsingBlock:^(NSDictionary *currentChildDictionary, NSUInteger idx, BOOL *stop) {
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
        [processedNestedAttributes replaceObjectAtIndex:[parsed.index integerValue] withObject:foundDictionary];
    } else {
        [processedNestedAttributes addObject:foundDictionary];
    }

    return [processedNestedAttributes copy];
}

- (NSArray *)railsProcessNestedAttributes:(NSArray *)nestedAttributes parsed:(HYPParsedRelationship *)parsed key:(NSString *)key
{
    NSMutableArray *processedNestedAttributes = [nestedAttributes mutableCopy];
    NSString *indexString = [parsed.index stringValue];

    __block NSMutableDictionary *foundDictionary;
    __block BOOL found = NO;
    for (NSDictionary *currentChildDictionary in nestedAttributes) {
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
        [processedNestedAttributes replaceObjectAtIndex:[parsed.index integerValue] withObject:childDictionary];
    } else {
        [processedNestedAttributes addObject:childDictionary];
    }

    return [processedNestedAttributes copy];
}

@end
