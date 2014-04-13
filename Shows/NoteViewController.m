//
//  NoteViewController.m
//  Shows
//
//  Created by CHIEN NGUYEN on 4/13/14.
//  Copyright (c) 2014 CHIEN NGUYEN. All rights reserved.
//

#import "NoteViewController.h"
#import "Note.h"

@interface NoteViewController ()

@end

@implementation NoteViewController
{
    NSMutableData *receivedData;
    NSMutableArray *noteArray;
    NSArray *sortedArray;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    noteArray = [[NSMutableArray alloc]init];
    [self getData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath
{
    return [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionViewHeader" forIndexPath:indexPath];
}

#pragma mark -  UICollectionView Datasource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [sortedArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    Note *n = [sortedArray objectAtIndex:indexPath.row];
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:1];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:3];
    
    titleLabel.text = n.title;
    textLabel.numberOfLines=0;
    textLabel.text = n.text;
    dateLabel.text = n.dateCreate;
    
    cell.backgroundColor = [UIColor lightGrayColor];
    //[cell addSubview:titleLabel];
    
    return cell;
}

//===================== connect to database and retrieve data ================
-(void)getData
{
    NSString *link = [NSString stringWithFormat:@"http://mydeatree.appspot.com/api/v1/public_ideas"];
    
    
    
    //build up the request that is to be send to server
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:link] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    
    /*
     * Create the connection with the request and start loading the data. This is asynchronous request
     * If NSURLConnection can’t create a connection for the request, initWithRequest:delegate: returns
     * nil. If the connection is successful, an instance of NSMutableData is created to store the data
     * that is provided to the delegate incrementally.
     */
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    if(connection)
        receivedData = [NSMutableData data];
    else
        NSLog(@"connection failed");
    
    link = nil;
    request = nil;
    connection = nil;
    
}

#pragma mark -NSURLConnection Delegate-

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    connection = nil;
    receivedData = nil;
    
    NSLog(@"Connection failed with error: %@",error.localizedDescription);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSLog(@"Request Complete,recieved %d bytes of data",receivedData.length);
    
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:receivedData options:
                          NSJSONReadingMutableContainers error:&error];
    //error parsing
    if(!json)
    {
        NSLog(@"%@", error);
    }
    else
        
    {
        NSArray *meta = [json valueForKey:@"meta"];
        NSArray *objects = [json valueForKey:@"objects"];
        
        for(NSDictionary *o in objects)
        {
        
            NSString *title = [o objectForKey:@"title"];
            NSString *text = [o objectForKey:@"text"];
            NSString *date = [o objectForKey:@"created_date"];
            
            
            Note *n = [[Note alloc]initNote:title setText:text setDate:date];
            
            [noteArray addObject:n];
        }
        
        
    }
    //sort by title
    sortedArray = [noteArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
    {
        NSString *first = [(Note*)a title];
        NSString *second = [(Note*)b title];
        
        return [first caseInsensitiveCompare:second];
    }];
    
    [self.collectionView reloadData];
    
    
    json = nil;
    error = nil;
    receivedData = nil;
    
}

- (IBAction)sortingOption:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    if(segmentedControl.selectedSegmentIndex ==0)//sort by title
    {
        sortedArray = [noteArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                       {
                           NSString *first = [(Note*)a title];
                           NSString *second = [(Note*)b title];
                           
                           return [first caseInsensitiveCompare:second];
                       }];
        [self.collectionView reloadData];
    }
    else if (segmentedControl.selectedSegmentIndex ==1)//sort by most recent
    {
        sortedArray = [noteArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                       {
                           NSString *first = [(Note*)a dateCreate];
                           NSString *second = [(Note*)b dateCreate];
                           
                           return [second caseInsensitiveCompare:first];
                       }];
        [self.collectionView reloadData];
    }
    else if (segmentedControl.selectedSegmentIndex ==2)//sort by oldest
    {
        sortedArray = [noteArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                       {
                           NSString *first = [(Note*)a dateCreate];
                           NSString *second = [(Note*)b dateCreate];
                           
                           return [first caseInsensitiveCompare:second];
                       }];
        [self.collectionView reloadData];
    }
    
}
@end
