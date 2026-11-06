#import "TYInfoViewController.h"
#import "TYTrackingService.h"
#import "TYArtwork.h"
@implementation TYInfoViewController
- (void)renderContent {
    [super renderContent];
    NSString *mode = self.screenMode ?: @"privacy";

    BOOL guidelines = [mode isEqual:@"guidelines"];
    [self addBackTitle:guidelines ? @"社区规范" : @"隐私说明"];
    [self add:[TYDesign label:guidelines ? @"同行，也相互尊重。" : @"你决定，哪些被看见。"
                         size:28
                       weight:UIFontWeightBold]];
    NSArray *texts=guidelines?@[@"真实发布",@"路线、时间、节奏和装备要求应准确。本版只支持免费自愿结伴，没有商业带队或交易。",@"尊重隐私",@"未经同意不公开他人的照片、身份、联系方式或集合位置。",@"友善表达",@"不发布骚扰、歧视、违法或误导内容。遇到问题可以举报和屏蔽。",@"按自身情况参加",@"留意路线开放与现场情况。记录数据与他人经验不能作为安全保证。"]:@[@"全部在本机运行",@"手机号、演示验证码、密码校验仅在本设备内运行，不发送真实短信。密码只保留加盐摘要。社区人物、互动和活动均为内置示例或本机操作，不提供跨设备社交通信、真实活动组织或系统推送。",@"资料与记录",@"轻量状态保存在本机NSUserDefaults，选择的照片缩放并重编码到Application Support。可在设置中清除。删除App也会清除这些本机数据。",@"定位按需授权",@"仅在开启真实GPS模式并开始记录时申请定位。示例与仅计时模式不请求位置。后台采集仅服务进行中的行程。",@"公开范围",@"作品只保存选定的摘要与心得快照，不包含精确轨迹、起终点、集合点与照片定位。所谓公开仅是本地演示状态变化。",@"正式上线",@"多人约行、公开社区、真实审核与客服需要后端和运营。当前回执仅本机可见，不代表外部工作人员收到。"];
    for (NSUInteger i = 0; i + 1 < texts.count; i += 2) {
        [self addSection:texts[i]];
        [self addText:texts[i + 1]];
    }
}
@end
