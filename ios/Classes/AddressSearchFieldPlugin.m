#import "AddressSearchFieldPlugin.h"
#if __has_include(<address_search_field/address_search_field-Swift.h>)
#import <address_search_field/address_search_field-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "address_search_field-Swift.h"
#endif

@implementation AddressSearchFieldPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAddressSearchFieldPlugin registerWithRegistrar:registrar];
}
@end
