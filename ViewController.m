//
//  ViewController.m
//  paralleldata
//
//  Created by Pedro Paulo de Amorim on 04/04/2019.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self process];
  // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}

int operations = 10;

- (void)process {
  
  // Allocated here for succinctness.
  NSOperationQueue *q = [[NSOperationQueue alloc] init];
  //All cores - 1 to keep the UI free
  unsigned long cores = [[NSProcessInfo processInfo] activeProcessorCount] - 2;
  [q setMaxConcurrentOperationCount:cores];
  printf("Cores %lu\n", cores);
  
  NSOperationQueue *qWrite = [[NSOperationQueue alloc] init];
  [qWrite setMaxConcurrentOperationCount:1];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"pedro.test"];

  NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
  [outputStream open];
  
  int bufferSize = 4096;
  int count = 100000000;
  
  for (int i = 1; i <= operations; i++) {
    [q addOperationWithBlock: ^{
      printf("Starting %i\n", i);
      NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
      for (int l = 0; l < count; l++) {
        [array addObject:[NSNumber numberWithFloat:1.0f + (i * l)]];
      }
      printf("Completed %i\n", i);
      [qWrite addOperationWithBlock: ^{
        
        printf("Writing %i\n", i);
        
        uint8_t buffer[bufferSize];
        int toWrite = count;
        
        while (toWrite > 0) {
          int minBufferSize = MIN(toWrite, bufferSize);
          for (int a = 0; a < bufferSize; a++) {
            buffer[a] = (uint8_t)[array[a] unsignedCharValue];
          }
          [outputStream write:buffer maxLength:bufferSize];
          toWrite -= minBufferSize;
        }
        
        if (i == operations) {
          printf("Process completed\n");
        }
        
      }];
    }];
  }
  
  [outputStream close];
  
}


@end
