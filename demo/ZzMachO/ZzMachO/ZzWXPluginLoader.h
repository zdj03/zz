//
//  ZzWXPluginLoader.h
//  ZzMachO
//
//  Created by 周登杰 on 2019/9/22.
//  Copyright © 2019 zdj. All rights reserved.
//


#import <Foundation/Foundation.h>


#define WeexPluginDATA __attribute((used, section("__DATA,WeexPlugin")))

#define WX_PLUGIN_NAME_SEPARATOR(module,jsname,classname,separator) module#separator#jsname#separator#classname

#define WX_PLUGIN_NAME(module,jsname,classname) WX_PLUGIN_NAME_SEPARATOR(module,jsname,classname,&)

#define WX_PlUGIN_EXPORT_MODULE_DATA(jsname,classname) \
char const * k##classname##Configuration WeexPluginDATA = WX_PLUGIN_NAME("module",jsname,classname);

#define  WX_PlUGIN_EXPORT_COMPONENT_DATA(jsname,classname)\
char const * k##classname##Configuration WeexPluginDATA = WX_PLUGIN_NAME("component",jsname,classname);

#define WX_PlUGIN_EXPORT_HANDLER_DATA(jsimpl,jsprotocolname)\
char const * k##jsimpl##jsprotocolname##Configuration WeexPluginDATA = WX_PLUGIN_NAME("protocol",jsimpl,jsprotocolname);



/**
 * this macro is used to auto regester moudule.
 *  example: WX_PlUGIN_EXPORT_MODULE(test,WXTestModule)
 **/
#define WX_PlUGIN_EXPORT_MODULE(jsname,classname) WX_PlUGIN_EXPORT_MODULE_DATA(jsname,classname)

/**
 *  this macro is used to auto regester component.
 *  example:WX_PlUGIN_EXPORT_COMPONENT(test,WXTestCompnonent)
 **/
#define WX_PlUGIN_EXPORT_COMPONENT(jsname,classname) WX_PlUGIN_EXPORT_COMPONENT_DATA(jsname,classname)

/**
 *  this macro is used to auto regester handler.
 *  example:WX_PlUGIN_EXPORT_HANDLER(WXImgLoaderDefaultImpl,WXImgLoaderProtocol)
 **/
#define WX_PlUGIN_EXPORT_HANDLER(jsimpl,jsprotocolname) WX_PlUGIN_EXPORT_HANDLER_DATA(jsimpl,jsprotocolname)


NS_ASSUME_NONNULL_BEGIN

@interface ZzWXPluginLoader : NSObject

+(void )registerPlugins;

@end
NS_ASSUME_NONNULL_END
