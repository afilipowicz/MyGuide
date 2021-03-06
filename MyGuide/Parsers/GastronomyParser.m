//
//  GastronomyParser.m
//  MyGuide
//
//  Created by Kamil Lelonek on 4/7/14.
//  Copyright (c) 2014 - Open Source (Apache 2.0 license). All rights reserved.
//

#import "GastronomyParser.h"
#import "Restaurant.h"
#import "Dish.h"
#import "GastronomyData.h"

static NSString *kXmlGastronomy = @"gastronomy";
static NSString *kXmlRestaurant = @"restaurant";
static NSString *kXmlLatitude   = @"lat";
static NSString *kXmlLongitude  = @"lon";
static NSString *kXmlOpen       = @"open";
static NSString *kXmlDish       = @"dish";
static NSString *kXmlPrice      = @"price";

@interface GastronomyParser ()

@property (nonatomic, readonly) NSMutableArray  *restaurants;
@property (nonatomic) Dish *currentDish;
@property (nonatomic) Restaurant *currentRestaurant;

@property BOOL insideDish;

@end

@implementation GastronomyParser

- (id) init {
    self = [super init];
    if(self) {
        _restaurants  = [NSMutableArray new];
        self.fileName = @"gastronomy";
    }
    return self;
}

- (void) parser: (NSXMLParser *)  parser
didStartElement: (NSString *)     elementName
   namespaceURI: (NSString *)     namespaceURI
  qualifiedName: (NSString *)     qName
     attributes: (NSDictionary *) attributeDict
{
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
    
    if ([elementName isEqualToString: kXmlRestaurant]) {
        _currentRestaurant = [[Restaurant alloc] initWithLatitude: [attributeDict valueForKey: kXmlLatitude]
                                                     andLongitude: [attributeDict valueForKey: kXmlLongitude]];
    }
    else if ([elementName isEqualToString: kXmlDish]) {
        _insideDish = YES;
        _currentDish = [Dish new];
    }
}

- (void) parser: (NSXMLParser *) parser
  didEndElement: (NSString *)    elementName
   namespaceURI: (NSString *)    namespaceURI
  qualifiedName: (NSString *)    qName
{
    if ([elementName isEqualToString: kXmlRestaurant]) {
        [_restaurants addObject: _currentRestaurant];
    }
    else if ([elementName isEqualToString: kXmlEN] || [elementName isEqualToString: kXmlPL]) {
        if(_insideDish) {
            [_currentDish setName: [self currentElement] withLanguage: elementName];
        }
        else {
            [_currentRestaurant setName: [self currentElement] withLanguage: elementName];
        }
    }
    else if ([elementName isEqualToString: kXmlOpen]) {
        _currentRestaurant.openHours = [self currentElement];
    }
    else if ([elementName isEqualToString: kXmlDish]) {
        _insideDish = NO;
        [_currentRestaurant addNewDish: _currentDish];
    }
    else if ([elementName isEqualToString: kXmlPrice]) {
        _currentDish.price = [NSNumber numberWithDouble: [[self currentElement] doubleValue]];
    }
}

- (void) parserDidEndDocument: (NSXMLParser *)parser {
    [super parserDidEndDocument: parser];
    GastronomyData *sharedParsedData = [GastronomyData sharedParsedData];
    sharedParsedData.restaurants = self.restaurants;
}

@end