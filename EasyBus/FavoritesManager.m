//
//  FavoritesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "FavoritesManager.h"

@interface FavoritesManager()
@property (strong, nonatomic) NSMutableArray* _favorites;
@property (strong, nonatomic) NSMutableArray* _groupes;
@end

@implementation FavoritesManager
@synthesize _favorites, _groupes;

#pragma singleton & init
//instancie le singleton
+ (FavoritesManager *)singleton
{
    static FavoritesManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FavoritesManager alloc] init];
    });
    return sharedInstance;
}

//constructeur
-(id)init {
    if ( self = [super init] ) {
        _favorites = [NSMutableArray new];
        [self loadFavoritesFromDisk];
        if (_favorites == nil) {
            _favorites = [NSMutableArray new];
        }
        _groupes = [NSMutableArray new];
        [self updateGroupes];
    }
    return self;
}

#pragma manage favorites
- (NSArray*) favorites {
    //retourne la liste des favoris
    return _favorites;
}

- (NSArray*) groupes {
    //retourne la liste des groupes de favoris (stopId+direction)
    //Remarque : pour économiser l'écriture d'une classe, on utilise un objet Favori pour représenter un Groupe
    return _groupes;
}

- (NSArray*) favoritesForGroupe:(Favorite*)groupe {
    //retourne la liste des favoris pour un arrêt et une direction, trié par delai croissant
    //Remarque : pour économiser l'écriture d'une classe, on utilise un objet Favori pour représenter un Groupe
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arret == %@ && direction == %@", groupe.arret, groupe.direction];
    return [_favorites filteredArrayUsingPredicate:predicate];
}

- (void) addFavorite:(Favorite*)favorite {
    //Recherche du favori
    Favorite* current = [self search:favorite];
    
    //ajoute un favoris en évitant les doublons
    if (current == nil) {
        //ajoute le favori
        [_favorites addObject:favorite];
        
        //tri des favoris
        NSArray* sortedFavorites = [_favorites sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [[(Favorite*)a ligne] intValue] > [[(Favorite*)b ligne] intValue];
        }];
        [_favorites removeAllObjects];
        [_favorites addObjectsFromArray:sortedFavorites];

        
        //met à jour les groupes
        [self updateGroupes];
        
        //sauve les favoris sur le disque
        [self saveFavoritesToDisk];
        
        //lance la notification favoritesUpdated
        [self sendUpdateNotification];
    }
}

- (void) removeFavorite:(Favorite*)favorite {
    //Recherche du favori
    Favorite* current = [self search:favorite];
    
    //Suppression du favori
    if (current != nil) {
        //supprime le favori
        [_favorites removeObject:current];

        //met à jour les groupes
        [self updateGroupes];
        
        //sauve les favoris sur le disque
        [self saveFavoritesToDisk];

        //lance la notification favoritesUpdated
        [self sendUpdateNotification];
    }
}

- (void) removeAllFavorites {
    //supprime tous les favoris
    [_favorites removeAllObjects];
    
    //met à jour les groupes
    [self updateGroupes];

    //sauve les favoris sur le disque
    [self saveFavoritesToDisk];
    
    //lance la notification favoritesUpdated
    [self sendUpdateNotification];
}

- (Favorite*) search:(Favorite*)newFavorite {
    NSUInteger idx = [_favorites indexOfObjectPassingTest:
                      ^ BOOL (Favorite* current, NSUInteger idx, BOOL *stop)
                      {
                          return [current.ligne isEqualToString:newFavorite.ligne] && [current.arret isEqualToString:newFavorite.arret] && [current.direction isEqualToString:newFavorite.direction] ;
                      }];
    
    if (idx != NSNotFound) {
        return [_favorites objectAtIndex:idx];
    }
    else {
        return nil;
    }
}

- (void) updateGroupes {
    //Remarque : pour économiser l'écriture d'une classe, on utilise un objet Favori pour représenter un Groupe
    
    //Purge des groupes
    [_groupes removeAllObjects];
    
    //Reconstitution des groupes
    for (Favorite* favorite in _favorites) {
        NSUInteger idx = [_groupes indexOfObjectPassingTest:
                          ^ BOOL (Favorite* current, NSUInteger idx, BOOL *stop)
                          {
                              return [current.arret isEqualToString:favorite.arret] && [current.direction isEqualToString:favorite.direction] ;
                          }];
        
        if (idx == NSNotFound) {
            [_groupes addObject:favorite];
        }
    }
}

#pragma manage notifications
- (void) sendUpdateNotification {
    //lance la notification favoritesUpdated
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavorites" object:self];
}

#pragma load and save favorites
- (void)saveFavoritesToDisk {
    //Save favorites
    @try {
        NSString * path = [self pathForDataFile];
        NSMutableDictionary *rootObject;
        rootObject = [NSMutableDictionary dictionary];
        [rootObject setValue:_favorites forKey:@"favorites"];
        [NSKeyedArchiver archiveRootObject:rootObject toFile: path];
    }
    @catch (NSException *exception) {
        //Message d'alerte
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Erreur lors de la sauvegarde des favoris" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)loadFavoritesFromDisk {
    @try {
        NSString     * path        = [self pathForDataFile];
        NSDictionary * rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        NSArray* favorites = [rootObject valueForKey:@"favorites"];
        NSArray* sortedFavorites = [favorites sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            return [[(Favorite*)a ligne] intValue] > [[(Favorite*)b ligne] intValue];
        }];
        _favorites = [NSMutableArray new];
        [_favorites addObjectsFromArray:sortedFavorites];

    }
    @catch (NSException *exception) {
    }
}

- (NSString *) pathForDataFile {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"favorites.save"];
}

@end
