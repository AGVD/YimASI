#include "hooking/DetourHook.hpp"
#include "hooks/Hooks.hpp"
#include "util/Joaat.hpp"

#include <rage/sysMemAllocator.hpp>
#include <script/tlsContext.hpp>

namespace NewBase
{
	void ModifyPoolSize(rage::atArray<CPoolSize>& sizes, const char* poolName, unsigned int size)
	{
		for (auto& entry : sizes)
		{
			if (!stricmp(entry.m_pool, poolName))
			{
				entry.m_size = size;
				return;
			}
		}

		sizes.append({(char*)poolName, size});
	}

	rage::fwConfigManagerImpl<CGameConfig>* GameFiles::ReadGameConfig(rage::fwConfigManagerImpl<CGameConfig>* manager, const char* file)
	{
		auto ret = BaseHook::Get<GameFiles::ReadGameConfig, DetourHook<decltype(&GameFiles::ReadGameConfig)>>()->Original()(manager, file);

		// increase pools
		// https://github.com/pnwparksfan/gameconfig/blob/master/versions/latest/gameconfig.xml

		return ret;
	}
}