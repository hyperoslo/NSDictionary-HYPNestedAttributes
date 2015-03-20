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
    NSMutableArray *nestedArrayAttributes;
    NSMutableDictionary *nestedDictionaryAttributes;

    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in sortedKeys) {
        HYPParsedRelationship *parsed = [key hyp_parseRelationship];
        if (parsed.toMany) {
            if (type == HYPJSONNestedAttributesType) {
                nestedArrayAttributes = attributesDictionary[parsed.relationship] ?: [NSMutableArray new];
                nestedArrayAttributes = [[self JSONProcessNestedAttributes:nestedArrayAttributes
                                                               parsed:parsed
                                                                  key:key] mutableCopy];
                attributesDictionary[parsed.relationship] = nestedArrayAttributes;
            } else if (type == HYPRailsNestedAttributesType) {
                NSString *attributesKey = [NSString stringWithFormat:@"%@%@", parsed.relationship, HYPNestedAttributesRailsKey];
                nestedDictionaryAttributes = attributesDictionary[attributesKey] ?: [NSMutableDictionary new];
                nestedDictionaryAttributes = [[self railsProcessNestedAttributes:nestedDictionaryAttributes
                                                                parsed:parsed
                                                                   key:key] mutableCopy];
                attributesDictionary[attributesKey] = nestedDictionaryAttributes;
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

- (NSDictionary *)railsProcessNestedAttributes:(NSMutableDictionary *)nestedAttributes parsed:(HYPParsedRelationship *)parsed key:(NSString *)key
{
    NSMutableDictionary *processedNestedAttributes = [nestedAttributes mutableCopy];
    NSString *indexString = [parsed.index stringValue];

    NSMutableDictionary *attributesDictionary = [processedNestedAttributes[indexString] mutableCopy];
    if (!attributesDictionary) {
        attributesDictionary = [NSMutableDictionary new];
    }

    NSString *attributeKey = [self valueForKey:key];
    attributesDictionary[parsed.attribute] = attributeKey;
    processedNestedAttributes[indexString] = [attributesDictionary copy];

    return [processedNestedAttributes copy];
}

@end
