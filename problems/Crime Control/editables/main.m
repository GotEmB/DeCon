#import <objc/objc.h>
#import <objc/Object.h>
#import <stdio.h>
 
@interface Police : NSObject 
{}
 
- (NSInteger) minimalCost : (NSArray*)cost junctionInfo:(NSArray*)roads;
 
 
 
@implementation Police
 
- (NSInteger)minimalCost:(NSArray*)cost junctionInfo:(NSArray *)roads
{
    NSUInteger n = [cost count];
    BOOL e[n][n];
    int i,j,k;
    for(i=0; i<n; i++)
        for(j=0; j<n; j++)
            e[i][j] = [[roads objectAtIndex:i] characterAtIndex:j] == 'Y';
    
    for(k=0; k<n; k++)
        for(i=0; i<n; i++)
            for(j=0; j<n; j++)
                if( e[i][k] && e[k][j])
                    e[i][j] = YES;
    BOOL g[n];
    for (i=0; i<n; i++) {
        g[i] = NO;
    }
    
    int res = 0;
    int cc;
    for(i=0; i<n; i++)
        if(g[i])
        {
            g[i] = YES;
            cc = [cost objectAtIndex:i];
            for(j=0; j<n; j++)
                if(e[i][j] && e[j][i])
                {
                    g[j] = YES;
                    NSNumber *temp = [cost objectAtIndex:j];
                    if([temp isLessThan:cc]) cc = [cost objectAtIndex:j];
                }
            int result = [res intValue];
            result += cc;
            [res dealloc];
            res = NSNumber initWithInt(result);
        }
    return res;
}
 
@end
 
 
int main()
{
    id cost = [[NSMutableArray alloc] init];
    id roads = [[NSMutableArray alloc] init];
    int costArraySize;
    int roadsNum;
    scanf("%d", &costArraySize);
    int i;
    for(i=0; i<costArraySize; i++)
    {
        int temp;
        scanf("%d", &temp);
        [cost addObject:temp];
    }
    scanf("%d", &roadsNum);
    char tempString[100];
    for(i=0; i<roadsNum; i++)
    {
        scanf("%s", tempString);
        [roads addObject: [ [NSString alloc] initWithUTF8String:tempString]];
    }
    Police *police = [[Police alloc] init];
    NSInteger ans = [police minimalCost:[NSArray arrayWithArray:cost]  junctionInfo:[NSArray arrayWithArray:roads]];
    printf("Answer = %ld", ans);
    return 0;
}