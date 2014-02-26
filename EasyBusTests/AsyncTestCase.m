//
//  IOCAsyncTesCase.m
//  EPGWithAvalaibleContent
//
//  Created by  on 11/07/13.
//  Copyright (c) 2013 Orange. All rights reserved.
//

#import "AsyncTestCase.h"

@implementation AsyncTestCase

// "re-sync" async operations
- (void)runTestWithBlock:(void (^)(void))block {
    //    [self runTestWithBlock:block andTimeout:0];
    
    self.semaphore = dispatch_semaphore_create(0);
    
    block();
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

// "re-sync" async operations with timeout
// - timeoutInSeconds = 0 --> no time out
- (void)runTestWithBlock:(void (^)(void))block andTimeout:(NSUInteger)timeoutInSeconds {
    self.semaphore = dispatch_semaphore_create(0);
    
    //Création du timer de timeout
    NSDate* timer = [[NSDate alloc] init];
    
    block();
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)  && (timeoutInSeconds==0?TRUE:([timer timeIntervalSinceNow] < timeoutInSeconds)))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
}

- (void)blockTestCompletedWithBlock:(void (^)(void))block {
    dispatch_semaphore_signal(self.semaphore);
    
    if (block) {
        block();
    }
}

// wait for notifications
- (NSNotification*)runTestWithBlock:(void (^)(void))block waitingForNotifications:(NSArray*)notifications withTimeout:(NSUInteger)timeoutInSeconds {
    //Création du sémaphore d'attente de la notification
    self.semaphore = dispatch_semaphore_create(0);
    
    //Abonnement aux notifications
    __block NSNotification* receivedNotification = nil;
    [notifications enumerateObjectsUsingBlock:^(NSString* notification, NSUInteger idx, BOOL *stop) {
        [[NSNotificationCenter defaultCenter] addObserverForName:notification object:nil queue:nil usingBlock:^(NSNotification * notification) {
            receivedNotification = notification;
            [self performBlockOnMainThread:^{dispatch_semaphore_signal(self.semaphore);}];
        }];
    }];
    
    //Création du timer de timeout
    NSDate* timer = [[NSDate alloc] init];
    
    //Exécution du block
    block();
    
    //Attente des notifications ou du timeout
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW) && -[timer timeIntervalSinceNow] < timeoutInSeconds) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    }

    //Vérification de la notification
    if (receivedNotification == nil) {
        [NSException raise:@"timeout" format:@"No notification received"];
    }
    
    //Désabonnement des notifications
    [notifications enumerateObjectsUsingBlock:^(NSString* notification, NSUInteger idx, BOOL *stop) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
    
    //retour
    return receivedNotification;
}

@end
