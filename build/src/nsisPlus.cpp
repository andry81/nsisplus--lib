/*
nsisPlus -- NsisPlus library external implementation as Nsis plugin.

Copyright (c) 2017 Andrey Dibrov (andry at inbox dot ru)
*/

#include "nsisPlus.h"
#include <shlwapi.h>
#include <assert.h>

#define if_break(x) if(!(x)); else switch(0) case 0: default:


HINSTANCE g_hInstance = HINSTANCE();
HWND g_hwndParent = HWND();


namespace {

UINT_PTR PluginCallback(enum NSPIM msg)
{
	return 0;
}

}

extern "C" {

LPSTR* CommandLineToArgvA(LPSTR lpCmdLine, int * pNumArgs)
{
	LPSTR* ret = NULL;
	int retval;
	LPWSTR lpWideCharStr = NULL;
	LPSTR* result = NULL;
	int numArgs = 0;
	LPWSTR* args = NULL;

	__try {
		retval = MultiByteToWideChar(CP_ACP, MB_ERR_INVALID_CHARS, lpCmdLine, -1, NULL, 0);
		if (!SUCCEEDED(retval)) {
			return NULL;
		}

		lpWideCharStr = (LPWSTR)malloc(retval * sizeof(WCHAR));
		if (!lpWideCharStr) {
			return NULL;
		}

		retval = MultiByteToWideChar(CP_ACP, MB_ERR_INVALID_CHARS, lpCmdLine, -1, lpWideCharStr, retval);
		if (!SUCCEEDED(retval)) {
			return NULL;
		}

		args = CommandLineToArgvW(lpWideCharStr, &numArgs);
		if (!args) {
			return NULL;
		}

		int storage = numArgs * sizeof(LPSTR);
		for (int i = 0; i < numArgs; ++ i)
		{
			BOOL lpUsedDefaultChar = FALSE;
			retval = WideCharToMultiByte(CP_ACP, 0, args[i], -1, NULL, 0, NULL, &lpUsedDefaultChar);
			if (!SUCCEEDED(retval)) {
				return NULL;
			}

			storage += retval;
		}

		result = (LPSTR*)LocalAlloc(LMEM_FIXED, storage);
		if (!result) {
			return NULL;
		}

		int bufLen = storage - numArgs * sizeof(LPSTR);
		LPSTR buffer = ((LPSTR)result) + numArgs * sizeof(LPSTR);
		for (int i = 0; i < numArgs; ++ i) {
			assert(bufLen > 0);
			BOOL lpUsedDefaultChar = FALSE;
			retval = WideCharToMultiByte(CP_ACP, 0, args[i], -1, buffer, bufLen, NULL, &lpUsedDefaultChar);
			if (!SUCCEEDED(retval)) {
				return NULL;
			}

			result[i] = buffer;
			buffer += retval;
			bufLen -= retval;
		}

		*pNumArgs = numArgs;

		// detach pointer
		ret = result;
		result = NULL;
	}
	__finally {
		if (lpWideCharStr) free(lpWideCharStr);
		if (result) LocalFree(result);
		if (args) LocalFree(args);
	}

	return ret;
}

}


BOOL WINAPI DllMain(HANDLE hInst, ULONG ul_reason_for_call, LPVOID lpReserved)
{
    g_hInstance = (HINSTANCE)hInst;
    return TRUE;
}


extern "C" {

NSISFunction(_DerefUint32A)
{
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	{
		unsigned int * ptr = 0;
		unsigned int offset = 0;

		// buffers at the end
		char buf_ptr[32] = {0};
		char buf_offset[32] = {0};

		g_hwndParent = hwndParent;

		PopStringA(buf_offset);
		PopStringA(buf_ptr);

		ptr = (unsigned int *)atoi(buf_ptr);
		if (!ptr) {
			PushStringA("0");
			return;
		}

		offset = atoi(buf_offset);

		_ui64toa(ptr[offset], buf_ptr, 10);
		PushStringA(buf_ptr);
	}
}

NSISFunction(_DerefUint32W)
{
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	{
		unsigned int * ptr = 0;
		unsigned int offset = 0;

		// buffers at the end
		WCHAR buf_ptr[32] = {0};
		WCHAR buf_offset[32] = {0};

		g_hwndParent = hwndParent;

		PopStringW(buf_offset);
		PopStringW(buf_ptr);

		ptr = (unsigned int *)_wtoi(buf_ptr);
		if (!ptr) {
			PushStringW(L"0");
			return;
		}

		offset = _wtoi(buf_offset);

		_ui64tow(ptr[offset], buf_ptr, 10);
		PushStringW(buf_ptr);
	}
}

NSISFunction(_GetArgvA)
{
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	{
		char ** ptr = 0;
		unsigned int offset = 0;

		// buffers at the end
		char buf_ptr[32] = {0};
		char buf_offset[32] = {0};

		g_hwndParent = hwndParent;

		PopStringA(buf_offset);
		PopStringA(buf_ptr);

		ptr = (char **)atoi(buf_ptr);
		if (!ptr) {
			PushStringA("");
			return;
		}

		offset = atoi(buf_offset);

		if (!ptr[offset]) {
			PushStringA("");
			return;
		}

		PushStringA(ptr[offset]);
	}
}

NSISFunction(_GetArgvW)
{
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	{
		WCHAR ** ptr = 0;
		unsigned int offset = 0;

		// buffers at the end
		WCHAR buf_ptr[32] = {0};
		WCHAR buf_offset[32] = {0};

		g_hwndParent = hwndParent;

		PopStringW(buf_offset);
		PopStringW(buf_ptr);

		ptr = (WCHAR **)_wtoi(buf_ptr);
		if (!ptr) {
			PushStringW(L"");
			return;
		}

		offset = _wtoi(buf_offset);

		if (!ptr[offset]) {
			PushStringW(L"");
			return;
		}

		PushStringW(ptr[offset]);
	}
}

NSISFunction(_CommandLineToArgvW)
{
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	{
		DWORD status = 0;
		LPWSTR* argv = NULL;
		LPWSTR pCmdLine = NULL;
		int NumArgs = 0;

		// buffers at the end
		WCHAR buf[256] = {0};

		g_hwndParent = hwndParent;

		PopStringW(buf);

		pCmdLine = (LPWSTR)_wtoi(buf);
		if (!pCmdLine) {
			PushStringW(L"0");
			PushStringW(L"0");
			PushStringW(L"ERROR");
			return;
		}

		SetLastError(0); // just in case

		argv = CommandLineToArgvW(pCmdLine, &NumArgs);
		if (!argv) {
			status = GetLastError();
			PushStringW(L"0");
			PushStringW(L"0");
			_swprintf(buf, L"ERROR %d", status);
			PushStringW(buf);
			return;
		}

		_ui64tow(NumArgs, buf, 10);
		PushStringW(buf);
		_ui64tow(*(DWORD*)&argv, buf, 10);
		PushStringW(buf);
		PushStringW(L"OK");
	}
}

NSISFunction(_CommandLineToArgvA)
{
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	{
		DWORD status = 0;
		LPSTR* argv = NULL;
		LPSTR pCmdLine = NULL;
		int NumArgs = 0;

		// buffers at the end
		char buf[256] = {0};

		g_hwndParent = hwndParent;

		PopStringA(buf);

		pCmdLine = (LPSTR)atoi(buf);
		if (!pCmdLine) {
			PushStringA("0");
			PushStringA("0");
			PushStringA("ERROR");
			return;
		}

		SetLastError(0); // just in case

		argv = CommandLineToArgvA(pCmdLine, &NumArgs);
		if (!argv) {
			status = GetLastError();
			PushStringA("0");
			PushStringA("0");
			sprintf(buf, "ERROR %d", status);
			PushStringA(buf);
			return;
		}

		_ui64toa(NumArgs, buf, 10);
		PushStringA(buf);
		_ui64toa(*(DWORD*)&argv, buf, 10);
		PushStringA(buf);
		PushStringA("OK");
	}
}

NSISFunction(_LocalFreeA)
{
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	{
		HLOCAL hMem = 0;

		// buffers at the end
		char buf[32] = {0};

		g_hwndParent = hwndParent;

		PopStringA(buf);

		LocalFree((HLOCAL)atoi(buf));
	}
}

NSISFunction(_LocalFreeW)
{
	EXDLL_INIT();
	extra->RegisterPluginCallback(g_hInstance, PluginCallback);
	{
		HLOCAL hMem = 0;

		// buffers at the end
		WCHAR buf[32] = {0};

		g_hwndParent = hwndParent;

		PopStringW(buf);

		LocalFree((HLOCAL)_wtoi(buf));
	}
}

}
