#import "EkeySdkModule.h"

#if __has_include("ekey_react_native_sdk-Swift.h")
#import "ekey_react_native_sdk-Swift.h"
#else
#import <ekey_react_native_sdk/ekey_react_native_sdk-Swift.h>
#endif

@implementation EkeySdkModule

RCT_EXPORT_MODULE(EkeySdk)

- (void)initiateLogin:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject
{
  [[EkeySdkImpl shared] initiateLoginWithResolve:^(NSDictionary *result) {
    resolve(result);
  }];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeEkeySdkSpecJSI>(params);
}

@end
