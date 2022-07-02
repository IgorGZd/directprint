#ifndef FLUTTER_PLUGIN_DIRECTPRINT_PLUGIN_H_
#define FLUTTER_PLUGIN_DIRECTPRINT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace directprint {

class DirectprintPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DirectprintPlugin();

  virtual ~DirectprintPlugin();

  // Disallow copy and assign.
  DirectprintPlugin(const DirectprintPlugin&) = delete;
  DirectprintPlugin& operator=(const DirectprintPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace directprint

#endif  // FLUTTER_PLUGIN_DIRECTPRINT_PLUGIN_H_
