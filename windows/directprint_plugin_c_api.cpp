#include "include/directprint/directprint_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "directprint_plugin.h"

void DirectprintPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  directprint::DirectprintPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
