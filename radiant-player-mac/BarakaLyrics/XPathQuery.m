//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "XPathQuery.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult,BOOL parentContent);
NSArray *PerformXPathQuery(xmlDocPtr doc, NSString *query);

NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult,BOOL parentContent)
{
    NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
    if (currentNode->name) {
        NSString *currentNodeContent = [NSString stringWithCString:(const char *)currentNode->name
                                                          encoding:NSUTF8StringEncoding];
        resultForNode[@"nodeName"] = currentNodeContent;
    }
    
    xmlChar *nodeContent = xmlNodeGetContent(currentNode);
    if (nodeContent != NULL) {
        NSString *currentNodeContent = [NSString stringWithCString:(const char *)nodeContent
                                                          encoding:NSUTF8StringEncoding];
        if (currentNodeContent == nil) {
            currentNodeContent = @"";
        }
        if ([resultForNode[@"nodeName"] isEqual:@"text"] && parentResult) {
            if (parentContent) {
                NSCharacterSet *charactersToTrim = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                parentResult[@"nodeContent"] = [currentNodeContent stringByTrimmingCharactersInSet:charactersToTrim];
                return nil;
            }
            if (currentNodeContent != nil) {
                resultForNode[@"nodeContent"] = currentNodeContent;
            }
            return resultForNode;
        } else {
            resultForNode[@"nodeContent"] = currentNodeContent;
        }
        xmlFree(nodeContent);
    }
    
    xmlAttr *attribute = currentNode->properties;
    if (attribute) {
        NSMutableArray *attributeArray = [NSMutableArray array];
        while (attribute) {
            NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
            NSString *attributeName = [NSString stringWithCString:(const char *)attribute->name
                                                         encoding:NSUTF8StringEncoding];
            if (attributeName) {
                attributeDictionary[@"attributeName"] = attributeName;
            }
            
            if (attribute->children) {
                NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary, true);
                if (childDictionary) {
                    attributeDictionary[@"attributeContent"] = childDictionary;
                }
            }
            
            if ([attributeDictionary count] > 0) {
                [attributeArray addObject:attributeDictionary];
            }
            attribute = attribute->next;
        }
        
        if ([attributeArray count] > 0) {
            resultForNode[@"nodeAttributeArray"] = attributeArray;
        }
    }
    
    xmlNodePtr childNode = currentNode->children;
    if (childNode) {
        NSMutableArray *childContentArray = [NSMutableArray array];
        while (childNode) {
            NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode,false);
            if (childDictionary) {
                [childContentArray addObject:childDictionary];
            }
            childNode = childNode->next;
        }
        if ([childContentArray count] > 0) {
            resultForNode[@"nodeChildArray"] = childContentArray;
        }
    }
    
    xmlBufferPtr buffer = xmlBufferCreate();
    xmlNodeDump(buffer, currentNode->doc, currentNode, 0, 0);
    NSString *rawContent = [NSString stringWithCString:(const char *)buffer->content encoding:NSUTF8StringEncoding];
    if (rawContent != nil) {
        resultForNode[@"raw"] = rawContent;
    }
    xmlBufferFree(buffer);
    return resultForNode;
}

NSArray *PerformXPathQuery(xmlDocPtr doc, NSString *query)
{
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
    /* Make sure that passed query is non-nil and is NSString object */
    if (query == nil || ![query isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    if(xpathCtx == NULL) {
        NSLog(@"Unable to create XPath context.");
        return nil;
    }
    
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if(xpathObj == NULL) {
        NSLog(@"Unable to evaluate XPath.");
        xmlXPathFreeContext(xpathCtx);
        return nil;
    }
    
    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    if (!nodes) {
        NSLog(@"Nodes was nil.");
        xmlXPathFreeObject(xpathObj);
        xmlXPathFreeContext(xpathCtx);
        return nil;
    }
    
    NSMutableArray *resultNodes = [NSMutableArray array];
    for (NSInteger i = 0; i < nodes->nodeNr; i++) {
        NSDictionary *nodeDictionary = DictionaryForNode(nodes->nodeTab[i], nil,false);
        if (nodeDictionary) {
            [resultNodes addObject:nodeDictionary];
        }
    }
    
    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx);
    
    return resultNodes;
}

NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query) {
    return PerformHTMLXPathQueryWithEncoding(document, query, nil);
}

NSArray *PerformHTMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding)
{
    xmlDocPtr doc;
    
    /* Load XML document */
    const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    
    doc = htmlReadMemory([document bytes], (int)[document length], "", encoded, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    if (doc == NULL) {
        NSLog(@"Unable to parse.");
        return nil;
    }
    
    NSArray *result = PerformXPathQuery(doc, query);
    xmlFreeDoc(doc);
    
    return result;
}

NSArray *PerformXMLXPathQuery(NSData *document, NSString *query) {
    return PerformXMLXPathQueryWithEncoding(document, query, nil);
}

NSArray *PerformXMLXPathQueryWithEncoding(NSData *document, NSString *query,NSString *encoding)
{
    xmlDocPtr doc;
    
    /* Load XML document */
    const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    
    doc = xmlReadMemory([document bytes], (int)[document length], "", encoded, XML_PARSE_RECOVER);
    
    if (doc == NULL) {
        NSLog(@"Unable to parse.");
        return nil;
    }
    
    NSArray *result = PerformXPathQuery(doc, query);
    xmlFreeDoc(doc);
    
    return result;
}