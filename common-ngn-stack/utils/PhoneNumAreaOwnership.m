//
//  PhoneNumAreaOwnership.m
//  WeiCall
//
//  Created by guobiao chen on 12-4-6.
//  Copyright (c) 2012年 SkyBroad. All rights reserved.
//

#import "PhoneNumAreaOwnership.h"

@implementation PhoneNumAreaOwnership

-(PhoneNumAreaOwnership*)init {
	if ((self = [super init])) {
		//
        areaArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc{
    [areaArray release];
    [super dealloc];
}

-(NSMutableArray *)subStringToSonSequence:(NSString *)operationString Separator:(NSString *)separatorString
{
    NSMutableArray * stringArray=[NSMutableArray arrayWithCapacity:3];
    NSRange range=[operationString rangeOfString:separatorString];
    if(range.location!=NSNotFound){
        NSString *firstStr=[operationString substringToIndex:range.location];
        NSString *lastStr=[operationString substringFromIndex:range.location+1];
        range=[lastStr rangeOfString:separatorString];
        [stringArray addObject:firstStr];
        NSString *tempStr;
        while(range.location!=NSNotFound){
            tempStr=[lastStr substringToIndex:range.location];
            lastStr=[lastStr substringFromIndex:range.location+1];
            range=[lastStr rangeOfString:separatorString];
            [stringArray addObject:tempStr];
        }
        if(lastStr!=nil)
            [stringArray addObject:lastStr];
    }
    return stringArray;
}

-(NSString *)clearOtherCharInString:(NSString *)phoneNumber symbols:(NSArray *) symbolsString
{
    NSString *returnString = nil;
    if((phoneNumber.length>0)&&([symbolsString count]>0)){
        NSRange range;
        returnString=phoneNumber;
        for(NSString * tempSymbols in symbolsString){
            range=[returnString rangeOfString:tempSymbols];
            if(range.location!=NSNotFound){
                returnString=[returnString stringByReplacingOccurrencesOfString:tempSymbols withString:@""];
                range=[returnString rangeOfString:tempSymbols];
                while(range.location!=NSNotFound){
                    returnString=[returnString stringByReplacingOccurrencesOfString:tempSymbols withString:@""];
                    range=[returnString rangeOfString:tempSymbols];
                }
            }
            
        }
    }
    return returnString;
}
/*
 
 
 
 */
-(NSArray *)writeTxtContentToArray:(NSString *)fileName
{
    NSError *error;
    //NSLog(@"fp %@", [NSBundle mainBundle]);
    NSString *textFileContents =[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    if(textFileContents==nil){
        NSLog(@"Error reading text file %@， %@", fileName, [error localizedFailureReason]);
        return nil;
    }
    NSArray *lines =[textFileContents componentsSeparatedByString:@"\n"];
    return lines;
}

-(NSString *)fileNameByNumberString:(NSString *)number currentDatabase:(NSArray *)current
{
    NSString *returnString=[number substringToIndex:3];
    if([current count]>0){
        NSString *tempString;
        BOOL hasData=NO;
        for(int i=0;i<[current count];i++){
            tempString=(NSString *)[current objectAtIndex:i];
            if([tempString isEqualToString:returnString]){
                hasData=YES;
                break;
            }
        }
        if(!hasData)
            returnString=nil;
    }
    return returnString;
}

/*
 Judgment operators By moblie & unicom & telecom database
 */
-(NSString *)operatorsByNumberString:(NSString *)number mobileDatabase:(NSArray *)mobile unicomDatabase:(NSArray *)unicom telecomDatabase:(NSArray *)telecom
{
    NSString *returnString = nil;
    NSString *numberString=[number substringToIndex:3];
    NSMutableArray *array=[[NSMutableArray alloc] init];
    [array addObject:mobile];
    [array addObject:unicom];
    [array addObject:telecom];
    BOOL isFinded=NO;
    for(NSArray * current in array){
        if([current count]>0){
            NSString *tempString;
            for(int i=0;i<[current count];i++){
                tempString=(NSString *)[current objectAtIndex:i];
                if([tempString isEqualToString:numberString]){
                    isFinded=YES;
                    if([array indexOfObject:current]==0){
                        returnString=@"移动";
                    }else if([array indexOfObject:current]==1){
                        returnString=@"联通";
                    }else if([array indexOfObject:current]==2){
                        returnString=@"电信";
                    }
                    break;
                }
            }
            if(isFinded)
                break;
        }
    }
    [array release];
    return returnString;
}

-(void)machineNumberAreaOwnership:(NSString *)phoneNumber
{
    NSArray *lines =[self writeTxtContentToArray:@"000"];
    NSEnumerator *nse=[lines objectEnumerator];
    NSString *operationString;
    NSString *separatorString=@";";
    while(operationString=[nse nextObject]){
        NSMutableArray *array=[self subStringToSonSequence:operationString Separator:separatorString];
        if([array count]!=0){
            NSString * equalStr=[array objectAtIndex:0];
            if([[phoneNumber substringToIndex:3] isEqualToString:equalStr])
            {
                NSString *appendStr=[array objectAtIndex:1];
                [areaArray addObject:appendStr];
                //[areaArray addObject:@"Machine"];//NSLocalizedString(@"Machine", @"Machine")];
                break;
            }
        }
    }
}


-(int)search:(NSArray *)array searchValue:(NSString *)key frontIndex:(int)low endIndex:(int)hight
{
    int mid;
    if(low>hight) return -1;
    mid=(low+hight)/2;
    NSString *tempStr=[array objectAtIndex:mid];
    NSMutableArray *currentArray=[self subStringToSonSequence:tempStr Separator:@";"];
    if([currentArray count]>0){
        NSString *value=[currentArray objectAtIndex:0];
        if([value intValue]==[key intValue]) return mid;
        else if([value intValue]>[key intValue])
            return [self search:array searchValue:key frontIndex:low endIndex:mid-1];
        else
            return [self search:array searchValue:key frontIndex:mid+1 endIndex:hight];
    }
    return -1;
}

-(void)searchAreaCode:(NSString *)phoneNumber
{
    
    NSArray *currentDatabase=[NSArray arrayWithObjects:@"130",@"131",@"132",@"133",@"134",@"135",@"136",@"137",@"138",@"139",@"150",@"151",@"152",@"153",@"155",@"156",@"157",@"158",@"159",@"186",@"188",@"189",nil];
    NSString *fileName=[self fileNameByNumberString:phoneNumber currentDatabase:currentDatabase];
    //NSLog(@"fileName %@", fileName);
    if(fileName!=nil){
        NSString *file=[phoneNumber substringToIndex:4];
        NSArray *lines =[self writeTxtContentToArray:file];//没有验证188X
        if(lines!=nil){
            NSRange range;
            range.location=4;
            range.length=3;
            NSString *key=[phoneNumber substringWithRange:range];
            int lineNumber=[self search:lines searchValue:key frontIndex:0 endIndex:[lines count]-1];
            if(lineNumber!=-1){
                NSString *value=[lines objectAtIndex:lineNumber];
                if(value!=nil){
                    NSString *separatorString=@";";
                    NSMutableArray *array=[self subStringToSonSequence:value Separator:separatorString];
                    if([array count]!=0){
                        NSString *appendStr=[array objectAtIndex:1];
                        [areaArray addObject:appendStr];
                        NSArray *mobile=[NSArray arrayWithObjects:@"134",@"135",@"136",@"137",@"138",@"139",@"150",@"151",@"152",@"157",@"158",@"159",@"188",nil];
                        NSArray *unicom=[NSArray arrayWithObjects:@"130",@"131",@"132",@"155",@"156",@"186",nil];
                        NSArray *telecom=[NSArray arrayWithObjects:@"133",@"153",@"189",nil];
                        NSString *operators=[self operatorsByNumberString:phoneNumber mobileDatabase:mobile unicomDatabase:unicom telecomDatabase:telecom];
                        [areaArray addObject:operators];
                    }
                }  
            }
        }
    }
}

-(void)mobileNumberAreaOwnership:(NSString *)phoneNumber
{
    NSArray *currentDatabase=[NSArray arrayWithObjects:@"130",@"131",@"132",@"133",@"134",@"135",@"136",@"137",@"138",@"139",@"150",@"151",@"152",@"153",@"155",@"156",@"157",@"158",@"159",@"186",@"188",@"189",nil];
    NSString *fileName=[self fileNameByNumberString:phoneNumber currentDatabase:currentDatabase];
    if(fileName!=nil){
        NSArray *lines =[self writeTxtContentToArray:fileName];
        NSEnumerator *nse=[lines objectEnumerator];
        NSString *operationString;
        NSString *separatorString=@";";
        BOOL index=YES;
        while((operationString=[nse nextObject])&&index){
            NSMutableArray *array=[self subStringToSonSequence:operationString Separator:separatorString];
            if([array count]!=0){
                NSString * equalStr=[array objectAtIndex:0];
                if([[phoneNumber substringToIndex:7] isEqualToString:equalStr])
                {
                    NSString *appendStr=[array objectAtIndex:2];
                    [areaArray addObject:appendStr];
                    NSArray *mobile=[NSArray arrayWithObjects:@"134",@"135",@"136",@"137",@"138",@"139",@"150",@"151",@"152",@"157",@"158",@"159",@"188",nil];
                    NSArray *unicom=[NSArray arrayWithObjects:@"130",@"131",@"132",@"155",@"156",@"186",nil];
                    NSArray *telecom=[NSArray arrayWithObjects:@"133",@"153",@"189",nil];
                    NSString *operators=[self operatorsByNumberString:phoneNumber mobileDatabase:mobile unicomDatabase:unicom telecomDatabase:telecom];
                    [areaArray addObject:operators];
                    index=NO;
                    break;
                }
            }
        } 
    }
}

-(void)enterpriseNumberAreaOwnership:(NSString *)phoneNumber
{
    NSString *str=[phoneNumber substringToIndex:4];
    if([str isEqualToString:@"4001"]||[str isEqualToString:@"4007"]){
        [areaArray addObject:@"移动"];//NSLocalizedString(@"Moile", @"Moile")];
        [areaArray addObject:@"400电话"];//NSLocalizedString(@"FourZeroZeroPhone", @"FourZeroZeroPhone")];
    }else if([str isEqualToString:@"4000"]||[str isEqualToString:@"4006"]){
        [areaArray addObject:@"联通"];//NSLocalizedString(@"Unicom", @"Unicom")];
        [areaArray addObject:@"400电话"];//NSLocalizedString(@"FourZeroZeroPhone", @"FourZeroZeroPhone")];
    }else if([str isEqualToString:@"4008"]){
        [areaArray addObject:@"电信"];//NSLocalizedString(@"Telecom", @"Telecom")];
        [areaArray addObject:@"400电话"];//NSLocalizedString(@"FourZeroZeroPhone", @"FourZeroZeroPhone")];
    }
}

-(NSMutableArray *)NumberAreaOwnership:(NSString *)phoneNumber
{
    @synchronized(areaArray){
        [areaArray removeAllObjects];
        //Remove excess symbols
        NSArray *symbols=[NSArray arrayWithObjects:@"%",@" ",@"(",@")",@"-",nil];
        phoneNumber=[self clearOtherCharInString:phoneNumber symbols:symbols];
        //For the first number in the judgement
        NSString *firstString=[phoneNumber substringToIndex:1];
        BOOL currentSwitchValue=YES;
        //machine
        if([firstString isEqualToString:@"0"]&&([phoneNumber length]>=7)){
            [self machineNumberAreaOwnership:phoneNumber];
            currentSwitchValue=NO;
        }
        //+ 8 cell phone number
        else if([firstString isEqualToString:@"+"]&&([phoneNumber length]>=11)){
            NSString *str=[phoneNumber substringToIndex:3];
            if([str isEqualToString:@"+86"]){
                phoneNumber=[phoneNumber substringFromIndex:3];
                //[self mobileNumberAreaOwnership:phoneNumber];
                [self searchAreaCode:phoneNumber];
                currentSwitchValue=NO;
            }else{
                str=[phoneNumber substringToIndex:4];
                if([str isEqualToString:@"+886"]){
                    [areaArray addObject:@"中国"];
                    [areaArray addObject:@"台湾"];
                    currentSwitchValue=NO;
                }else if([str isEqualToString:@"+852"]){
                    [areaArray addObject:@"中国"];
                    [areaArray addObject:@"香港"];
                    currentSwitchValue=NO;
                }else if([str isEqualToString:@"+853"]){
                    [areaArray addObject:@"中国"];
                    [areaArray addObject:@"澳门"];
                    currentSwitchValue=NO;
                }
            }
        }
        //Mobile phone number
        else if([firstString isEqualToString:@"1"]&&([phoneNumber length]==11)){
            //[self mobileNumberAreaOwnership:phoneNumber];
            [self searchAreaCode:phoneNumber];
            currentSwitchValue=NO;
        }
        //enterprise phone 400&&800
        if(currentSwitchValue&&([phoneNumber length]==10)){
            NSString *str=[phoneNumber substringToIndex:3];
            if([str isEqualToString:@"400"]){
                [self enterpriseNumberAreaOwnership:phoneNumber];
            }else if([str isEqualToString:@"800"]){
                [areaArray addObject:@"800"];
                [areaArray addObject:@"企业电话"];//NSLocalizedString(@"Enterprise phone", @"Enterprise phone")];
            }
        }
    }
    return areaArray;
}


@end
