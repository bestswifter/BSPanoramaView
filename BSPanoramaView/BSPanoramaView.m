//
//  BSPanoramaView.m
//  BSPanoramaView
//
//  Created by 张星宇 on 11/15/17.
//  Copyright © 2017 bestswifter. All rights reserved.
//

#import "BSPanoramaView.h"

@interface BSPanoramaView ()

#pragma -mark OpenGL 相关属性
@property (nonatomic, assign) BOOL shouldUnload;               /// 索引数
@property (nonatomic, assign) int numIndices;                  /// 索引数
@property (nonatomic, assign) GLuint vertexIndicesBufferID;    /// 顶点索引缓存指针
@property (nonatomic, assign) GLuint vertexBufferID;           /// 顶点缓存指针
@property (nonatomic, assign) GLuint vertexTexCoordID;         /// 纹理缓存指针
@property (nonatomic, strong) GLKBaseEffect *effect;           /// 着色器

#pragma -mark 手势相关属性
@property (nonatomic, strong) UIPanGestureRecognizer *pan;     /// 滑动手势
@property (nonatomic, assign) CGFloat panX;                    /// 水平位移
@property (nonatomic, assign) CGFloat panY;                    /// 垂直位移
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch; /// 缩放手势
@property (nonatomic, assign) CGFloat scale;                   /// 缩放比例

@end

@implementation BSPanoramaView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.enableSetNeedsDisplay = NO;
        [[PanoramaManager sharedInstance] registerView:self];
        [self setupOpenGL];          /// OpenGL 初始化设置
        [self addGestureRecognizer]; /// 添加手势
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName {
    self = [self initWithFrame:frame];
    if (self) {
        [self setImageWithName:imageName];
    }
    return self;
}

- (void)dealloc {
    [self unloadImage];
}

- (void)setImageWithName:(NSString *)imageName {
    self.shouldUnload = NO;
    /// 将图片转换成为纹理信息，由于OpenGL的默认坐标系设置在左下角, 而GLKit在左上角, 因此需要转换
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
    UIImage *textureImage = [UIImage imageNamed:imageName];
    GLKTextureLoader *loader = [[GLKTextureLoader alloc] initWithSharegroup:self.context.sharegroup];
    [loader textureWithCGImage:textureImage.CGImage options:options queue:dispatch_get_main_queue() completionHandler:^(GLKTextureInfo * _Nullable textureInfo, NSError * _Nullable outError) {
        
        if (self.shouldUnload) {  // 因为是异步加载，所以需要考虑调用完 unloadImage 才加载成功的情况
            [[PanoramaManager sharedInstance] unRegisterView:self];
            GLuint name = textureInfo.name;
            glDeleteTextures(1, &name);
            glDrawElements(GL_TRIANGLES, self.numIndices, GL_UNSIGNED_SHORT, 0);
            return ;
        }
        
        /// 设置着色器的纹理
        self.effect = [[GLKBaseEffect alloc] init];
        self.effect.texture2d0.enabled = GL_TRUE;
        self.effect.texture2d0.name = textureInfo.name;
    }];
}

- (void)unloadImage {
    self.shouldUnload = YES;
    [[PanoramaManager sharedInstance] unRegisterView:self];
    
    GLuint name = self.effect.texture2d0.name;
    glDeleteTextures(1, &name);
    glDrawElements(GL_TRIANGLES, self.numIndices, GL_UNSIGNED_SHORT, 0);
}

- (void)setupOpenGL {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    /// 设置buffer
    GLfloat *vVertices = NULL;  /// 顶点
    GLfloat *vTextCoord = NULL; /// 纹理
    GLushort *indices = NULL;   /// 索引
    
    int numVertices = 0;
    self.numIndices = esGenSphere(100, 1.0, &vVertices, &vTextCoord, &indices, &numVertices);
    
    /// 索引
    glGenBuffers(1, &_vertexIndicesBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.vertexIndicesBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.numIndices*sizeof(GLushort), indices, GL_STATIC_DRAW);
    
    /// 顶点数据
    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, numVertices*3*sizeof(GLfloat), vVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);   /// 顶点位置属性
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*3, NULL);
    
    /// 纹理数据
    glGenBuffers(1, &_vertexTexCoordID);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexTexCoordID);
    glBufferData(GL_ARRAY_BUFFER, numVertices*2*sizeof(GLfloat), vTextCoord, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);  /// 纹理位置属性
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*2, NULL);
}

#pragma mark --- 生成球的几何结构----
// 参考：https://github.com/danginsburg/opengles-book-samples/blob/604a02cc84f9cc4369f7efe93d2a1d7f2cab2ba7/iPhone/Common/esUtil.h#L110
int esGenSphere(int numSlices, float radius, float **vertices,
                float **texCoords, uint16_t **indices, int *numVertices_out) {
    int numParallels = numSlices / 2;
    int numVertices = (numParallels + 1) * (numSlices + 1);
    int numIndices = numParallels * numSlices * 6;
    float angleStep = (2.0f * 3.14159265358f) / ((float) numSlices);
    
    if (vertices != NULL) {
        *vertices = malloc(sizeof(float) * 3 * numVertices);
    }
    
    if (texCoords != NULL) {
        *texCoords = malloc(sizeof(float) * 2 * numVertices);
    }
    
    if (indices != NULL) {
        *indices = malloc(sizeof(uint16_t) * numIndices);
    }
    
    for (int i = 0; i < numParallels + 1; i++) {
        for (int j = 0; j < numSlices + 1; j++) {
            int vertex = (i * (numSlices + 1) + j) * 3;
            
            if (vertices) {
                (*vertices)[vertex + 0] = radius * sinf(angleStep * (float)i) * sinf(angleStep * (float)j);
                (*vertices)[vertex + 1] = radius * cosf(angleStep * (float)i);
                (*vertices)[vertex + 2] = radius * sinf(angleStep * (float)i) * cosf(angleStep * (float)j);
            }
            
            if (texCoords) {
                int texIndex = (i * (numSlices + 1) + j) * 2;
                (*texCoords)[texIndex + 0] = (float)j / (float)numSlices;
                (*texCoords)[texIndex + 1] = 1.0f - ((float)i / (float)numParallels);
            }
        }
    }
    
    // Generate the indices
    if (indices != NULL) {
        uint16_t *indexBuf = (*indices);
        for (int i = 0; i < numParallels ; i++) {
            for (int j = 0; j < numSlices; j++) {
                *indexBuf++ = i * (numSlices + 1) + j;
                *indexBuf++ = (i + 1) * (numSlices + 1) + j;
                *indexBuf++ = (i + 1) * (numSlices + 1) + (j + 1);
                
                *indexBuf++ = i * (numSlices + 1) + j;
                *indexBuf++ = (i + 1) * (numSlices + 1) + (j + 1);
                *indexBuf++ = i * (numSlices + 1) + (j + 1);
            }
        }
    }
    
    if (numVertices_out) {
        *numVertices_out = numVertices;
    }
    
    return numIndices;
}

#pragma mark 手势添加与识别
- (void)addGestureRecognizer{
    /// 平移手势
    self.pan =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:self.pan];
    
    /// 捏合手势
    self.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:self.pinch];
    self.scale = 1.428571f;
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self];
    self.panX += point.x;
    self.panY += point.y;
    
    [pan setTranslation:CGPointZero inView:self];  //每次变换之后, 把改变值归零
}

- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
    self.scale *= pinch.scale;
    pinch.scale = 1.0;
}

#pragma mark 绘制
- (void)drawRect:(CGRect)rect {
    [self update];
    [self.effect prepareToDraw];
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glDrawElements(GL_TRIANGLES, self.numIndices, GL_UNSIGNED_SHORT, 0);
}

- (void)update{
    CGSize size = self.bounds.size;
    float aspect = fabs(size.width / size.height);
    
    /**
     *  根据缩放比例, 设置焦距
     */
    CGFloat ovyRadians = 100 / self.scale;
    
    // ovyRadians 不小于 50, 不大于 120;
    if (ovyRadians < 50) {
        ovyRadians = 50;
        self.scale = 1 / (50.0 / 100);
    }
    if (ovyRadians > 120) {
        ovyRadians = 120;
        self.scale = 1 / (120.0 / 100);
    }
    
    /**GLKMatrix4MakePerspective 配置透视图
     第一个参数, 类似于相机的焦距, 比如10表示窄角度, 100表示广角 一般65-75;
     第二个参数: 表示时屏幕的纵横比
     第三个, 第四参数: 是为了实现透视效果, 近大远处小, 要确保模型位于远近平面之间
     */
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(ovyRadians), aspect, 0.1f, 400.0f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, -1.0f, 1.0f, 1.0f);
    
    GLKMatrix4 rotation = GLKMatrix4MakeWithQuaternion([PanoramaManager sharedInstance].lastQuaternion);
    
    projectionMatrix = GLKMatrix4RotateX(projectionMatrix, -0.005*self.panY);
    projectionMatrix = GLKMatrix4Multiply(projectionMatrix, rotation);
    
    /// 为了保证在水平放置手机的时候, 是从下往上看, 因此首先坐标系沿着x轴旋转90度
    projectionMatrix = GLKMatrix4RotateX(projectionMatrix, M_PI_2);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, 0.005*self.panX);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
}

@end

@interface PanoramaManager()

@property (nonatomic, strong) NSHashTable <BSPanoramaView *>*panoViews;
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation PanoramaManager

+ (PanoramaManager *)sharedInstance {
    static PanoramaManager *panoramaManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        panoramaManager = [[PanoramaManager alloc] init];
    });
    return panoramaManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;  //设置运动更新间隔
        _motionManager.showsDeviceMovementDisplay = YES;         // 是否展示运动
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
        
        _panoViews = [[NSHashTable alloc] initWithOptions:NSHashTableWeakMemory capacity:2];
        
        CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(display:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)registerView:(BSPanoramaView *)view {
    [self.panoViews addObject:view];
}

- (void)unRegisterView:(BSPanoramaView *)view {
    if ([self.panoViews containsObject:view]) {
        [self.panoViews removeObject:view];
    }
}

- (void)display:(CADisplayLink *)displayLink {
    if (self.motionManager) {  // 从后台回到前台时，CoreMotion 可能还没有工作，这里会拿到空的四元数，导致渲染失败
        CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
        
        double w = deviceMotion.attitude.quaternion.w;
        double wx = deviceMotion.attitude.quaternion.x;
        double wy = deviceMotion.attitude.quaternion.y;
        double wz = deviceMotion.attitude.quaternion.z;
        self.lastQuaternion = GLKQuaternionMake(-wx, wy, wz, w);
    }
    
    for (BSPanoramaView *view in self.panoViews) {
        if (view) {
            [view display];
        }
    }
}

@end
