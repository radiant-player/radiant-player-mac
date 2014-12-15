/*
 * Swizzle.h
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#ifndef RP_SWIZZLE_H
#define RP_SWIZZLE_H

#import <objc/runtime.h>

void SwizzleInstanceMethods(Class class, SEL methodA, SEL methodB);

#endif
