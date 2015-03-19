#import "NSDictionary+HYPNestedAttributes.h"

#import "HYPParsedRelationship.h"

#import "NSString+HYPRelationshipParser.h"

@implementation NSDictionary (HYPNestedAttributes)

- (NSDictionary *)hyp_nestify
{
    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];

    NSMutableDictionary *parsedIndexes = [NSMutableDictionary new];

    NSMutableArray *relationIndexes = [NSMutableArray new];
    for (NSString *key in sortedKeys) {
        HYPParsedRelationship *parsed = [key hyp_parseRelationship];
        if (parsed.toMany) {
            NSString *indexString = [parsed.index stringValue];

            __block NSMutableDictionary *foundDictionary;
            __block BOOL found = NO;
            for (NSDictionary *one in relationIndexes) {
                if ([one.allKeys.firstObject isEqualToString:indexString]) {
                    foundDictionary = [one[indexString] mutableCopy];
                    found = YES;
                }
            }

            if (!foundDictionary) {
                foundDictionary = [NSMutableDictionary new];
            }

            NSString *attributeKey = [self valueForKey:key];
            foundDictionary[parsed.attribute] = attributeKey;

            if (found) {
                [relationIndexes replaceObjectAtIndex:[parsed.index integerValue] withObject:@{indexString : foundDictionary}];
            } else {
                [relationIndexes addObject:@{indexString : foundDictionary}];
            }
        } else {
            NSString *selfKey = [self valueForKey:key];
            parsedIndexes[parsed.attribute] = selfKey;
        }
    }

    parsedIndexes[@"contacts_attributes"] = relationIndexes;

    return parsedIndexes;
}

@end
