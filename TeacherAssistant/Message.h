
// Data model object that stores a single message
@interface Message : NSObject
{
}

@property (nonatomic) int rowid;
// The sender of the message. If nil, the message was sent by the user.
@property (nonatomic, copy) NSString* respondUser;
@property (nonatomic, copy) NSString* respondName;

// When the message was sent
@property (nonatomic, copy) NSDate* date;

@property (nonatomic, copy) NSString* msgType;
//0=发送 1=接收
@property (nonatomic) int ifReceive;
@property (nonatomic) int ifRead;
// The text of the message
@property (nonatomic, copy) NSString* text;
@property (nonatomic, copy) UIImage* img;
// This doesn't really belong in the data model, but we use it to cache the
// size of the speech bubble for this message.
@property (nonatomic, assign) CGSize bubbleSize;
@property (nonatomic) int ifsuc;
@property (nonatomic, copy) NSString* imageUrl;
@property (nonatomic, copy) NSString* linkUrl;
@property (nonatomic, copy) NSMutableArray* msgIdArray;

// Determines whether this message as sent by the user of the app. We will
// display such messages on the right-hand side of the screen.


@end
