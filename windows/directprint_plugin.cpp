#include "directprint_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_result_functions.h>

#include <sstream>
#include <vector>
#include <string>

namespace directprint {

    using flutter::EncodableMap;
    using flutter::EncodableValue;

    // static
    void DirectprintPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar) {
      auto channel =
          std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
              registrar->messenger(), "directprint",
              &flutter::StandardMethodCodec::GetInstance());

      auto plugin = std::make_unique<DirectprintPlugin>();

      channel->SetMethodCallHandler(
          [plugin_pointer = plugin.get()](const auto &call, auto result) {
            plugin_pointer->HandleMethodCall(call, std::move(result));
          });

      registrar->AddPlugin(std::move(plugin));
    }

    DirectprintPlugin::DirectprintPlugin() {}

    DirectprintPlugin::~DirectprintPlugin() {}

    std::string GetUrlArgumentString(const flutter::MethodCall<>& method_call, std::string att) {
      std::string url;
      const auto* arguments = std::get_if<EncodableMap>(method_call.arguments());
      if (arguments) {
        auto url_it = arguments->find(EncodableValue(att));
        if (url_it != arguments->end()) {
          url = std::get<std::string>(url_it->second);
        }
      }
      return url;
    }

    std::vector<BYTE> GetUrlArgumentBytes(const flutter::MethodCall<>& method_call, std::string att) {
      std::vector<BYTE> ndata;
      const auto* arguments = std::get_if<EncodableMap>(method_call.arguments());
      if (arguments) {
        auto url_it = arguments->find(EncodableValue(att));
        if (url_it != arguments->end()) {
            ndata = std::get<std::vector<BYTE>>(url_it->second);
        }
      }
      return ndata;
    }

    // Source:
    // https://docs.microsoft.com/hr-hr/windows/win32/printdocs/sending-data-directly-to-a-printer?redirectedfrom=MSDN
    //
    // RawDataToPrinter - sends binary data directly to a printer
    //
    // szPrinterName: NULL-terminated string specifying printer name
    // szJobName:     NULL-terminated string specifying job name in print queue
    // lpData:        Pointer to raw data bytes
    // dwCount        Length of lpData in bytes
    //
    // Returns: 
    // 
    // 0 - No error
    // 1 - Error: Opening Printer
    // 2 - Error: Opening Document
    // 3 - Error: Starting Page
    // 4 - Error: Printing Count
    //
    int32_t RawDataToPrinter(LPTSTR szPrinterName, LPTSTR szJobName, LPBYTE lpData, DWORD dwCount)
    {
        BOOL       bStatus = FALSE;
        HANDLE     hPrinter = NULL;
        DOC_INFO_1 DocInfo;
        DWORD      dwJob = 0L;
        DWORD      dwBytesWritten = 0L;
        int32_t    errcode;

        bStatus = OpenPrinter(szPrinterName, &hPrinter, NULL);
        if (bStatus) {

            DocInfo.pDocName = szJobName;
            DocInfo.pOutputFile = NULL;
            DocInfo.pDatatype = (LPTSTR)(L"RAW");

            dwJob = StartDocPrinter(hPrinter, 1, (LPBYTE)&DocInfo);
            if (dwJob > 0) {
                bStatus = StartPagePrinter(hPrinter);
                if (bStatus) {
                    bStatus = WritePrinter(hPrinter, lpData, dwCount, &dwBytesWritten);
                    EndPagePrinter(hPrinter);
                } else {
                    // Error: Starting page
                    errcode = 3;
                }
                EndDocPrinter(hPrinter);

                if (!bStatus || (dwBytesWritten != dwCount)) {
                    bStatus = FALSE;
                    // Error: Printing count
                    errcode = 4;
                }
                else {
                    bStatus = TRUE;
                    // No error
                    errcode = 0;
                }
            } else {
                // Error: Opening document
                errcode = 2;
            }
            ClosePrinter(hPrinter);

        } else {
          // Error: OpenPrinter
            errcode = 1;
        }

        return errcode;
    }

    void DirectprintPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
      
        if (method_call.method_name().compare("directPrint") == 0) {

          std::string prnName = GetUrlArgumentString(method_call, "printer");
          std::string jobName = GetUrlArgumentString(method_call, "job");

           std::wstring prnNameWstr = std::wstring(prnName.begin(), prnName.end());
           std::wstring jobNameWstr = std::wstring(jobName.begin(), jobName.end());

          std::vector<BYTE> databytes = GetUrlArgumentBytes(method_call, "data");
          size_t dataLen = databytes.size();

          uint32_t printingRes = RawDataToPrinter(
            (LPTSTR)prnNameWstr.c_str(),
            (LPTSTR)jobNameWstr.c_str(),
            (LPBYTE)databytes.data(),
            DWORD(dataLen));

          std::ostringstream dpStream;

          if (printingRes == 0) {
            dpStream << "OK";
          } else {
            dpStream << "ERROR:" << printingRes;
          }

          result->Success(flutter::EncodableValue(dpStream.str()));
      } else {
        result->NotImplemented();
      }
    }

}  // namespace directprint
