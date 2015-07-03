/*
 * Swizzle.c
 *
 * Created by Sajid Anwar.
 *
 * Subject to terms and conditions in LICENSE.md.
 *
 */

#include "Swizzle.h"

void SwizzleInstanceMethods(Class class, SEL methodA, SEL methodB)
{
    Method originalMethod = class_getInstanceMethod(class, methodA);
    Method swizzledMethod = class_getInstanceMethod(class, methodB);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}