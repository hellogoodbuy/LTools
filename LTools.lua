script_name('LTools')
script_author('GoodBuy')
script_version('0.2')


require 'moonloader'
local imgui 	= 	require 'imgui'
local fa 		= 	require 'fAwesome5'
local encoding 	= 	require 'encoding'
local se 		=	require 'lib.samp.events'
encoding.default = 'CP1251'

local mc, sc, wc = '{006AC2}', '{006D86}', '{FFFFFF}'
local bbc = 0x006AC2
local tag = 'L'..wc..'Tools | '

local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local fontsize,headersize, fa_font = nil
local u8 = encoding.UTF8
local w, h = getScreenResolution()

-- В КОНФИГ:  

local Organization = ""
local Post = ""
local Rank = 0
local stateLeaderOrNot = false
local doLeader = false



local fractions = { 
 'Управление полиции ЛС', 
 'ФСБ', 
 'Армия Сан-Фиерро', 
 'Городская больница ЛС', 
 'La Cosa Nostra', 
 'Yakuza', 
 'Мэрия', 
 'Закрыто', 
 'Закрыто', 
 'Управление полиции СФ', 
 'Инструкторы', 
 'The Ballas', 
 'Vagos', 
 'Русская мафия', 
 'Grove Street', 
 'Радиоцентр', 
 'Aztecas', 
 'The Rifa', 
 'Армия Лас-Вентураса', 
 'Закрыто', 
 'Управление полиции ЛВ', 
 'Закрыто', 
 'Хитманы', 
 'Стритрейсеры', 
 'ОМОН', 
 'Администрация Президента', 
 'Казино "4 дракона"', 
 'Казино "Калигула"' 
}

local selected = 1
local menu = imgui.ImBool(false)

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	
	if not checkServer(select(1, sampGetCurrentServerAddress())) then
		addLeaderMessage('Скрипт работает только на проекте '..mc..'Russia RolePlay')
		thisScript():unload()
	end
	stateLeaderOrNot = true
    sampSendChat("/mm")
	
	while stateLeaderOrNot do wait(0) end
	if doLeader and not stateLeaderOrNot then
	    addLeaderMessage("Приятного использования.")
	else
		addLeaderMessage("Предназначено только для лидеров организаций. Скрипт завершил работу.")
		--thisScript():unload()
	end
	wait (50)
	checkUpdate()
	while true do
		wait(0)
		
		imgui.Process = menu.v

		if isKeyCheckAvailable() and isKeyJustPressed(VK_X) then
			menu.v = not menu.v
		end
		
	end
end

function se.onSendChat(msg)
    if stateLeaderOrNot and msg ~= "/mm" then
        addLeaderMessage("Идёт проверка, доступ к чату запрещён.")
        return false
    end
end

function se.onShowDialog(dialogId, style, title, button1, button2, text)
	if stateLeaderOrNot then
        if title:find("Меню игрока") then
            sampSendDialogResponse(9623, 1, 0, -1)
            return false
        end
        if dialogId == 1932 or title:find("Статистика игрока") then 
            for text in text:gmatch("[^\r\n]+") do
                if text:find("Организация: %s+(.*)") then
					Organization = text:match("Организация: %s+(.*)")
				end
				if text:find("Ранг: ") then
					Post, Rank = text:match("Ранг: %s+(.*)%((%d+)%)")
				end
				if Organization:find("Неизвестно") then doLeader = false stateLeaderOrNot = false end
				
				if not Organization:find("Управление полиции ЛС")
				and not Organization:find("Управление полиции СФ")
				and not Organization:find("Управление полиции ЛВ") then
                    if tonumber(Rank) == 10 then
                        doLeader = true
                        stateLeaderOrNot = false
                    end
                else
                    if tonumber(Rank) == 15 then
                        doLeader = true
                        stateLeaderOrNot = false
                    end
                end
            end
            return false
        end
    end
end

function imgui.BeforeDrawFrame()
	if headersize == nil then
		headersize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 25.5, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
	end

    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 18.5, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
    end

	if fa_font == nil then
        local font_config = imgui.ImFontConfig() 
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 18.5, font_config, fa_glyph_ranges)
    end
end

function imgui.OnDrawFrame()
	if menu.v then
		imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(w / 2, 576), imgui.Cond.FirstUseEver)
		imgui.Begin('Gang Menu', menu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

		imgui.BeginChild("##left_panel", imgui.ImVec2(w / 13, 0), false, imgui.WindowFlags.NoScrollbar)
			if imgui.ButtonMainMenu(fa.ICON_FA_COGS .. u8' НАСТРОЙКИ', imgui.ImVec2(w / 13, 0)) then
				selected = 1
			end
			if imgui.ButtonMainMenu(fa.ICON_FA_TV .. u8' ЕЩЁ ЧТО ТО', imgui.ImVec2(w / 13, 24)) then
				selected = 2
			end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##gen_panel", imgui.ImVec2(w / 3 + 129, 576 - 56), false, imgui.WindowFlags.NoScrollbar)
					if selected == 1 then
						imgui.SetCursorPosX(10)
						imgui.SetCursorPosY(5)
						imgui.Header(u8'Настройки ')
				elseif selected == 2 then
					imgui.SetCursorPosX(10)
						imgui.SetCursorPosY(5)
						imgui.Header(u8'Ещё что то ')
				end
		imgui.EndChild()
		imgui.End()		
	end
end

function isKeyCheckAvailable() 
	if not isSampfuncsLoaded() then
		return not isPauseMenuActive()
	end
	local result = not isSampfuncsConsoleActive() and not isPauseMenuActive()
	if isSampLoaded() and isSampAvailable() then
		result = result and not sampIsChatInputActive() and not sampIsDialogActive()
	end
	return result
end

function imgui.Header(name)
	imgui.PushFont(headersize)
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.20, 0.25, 0.29, 1.00))
    local result = imgui.Text(name, size)
    imgui.PopStyleColor(1)
	imgui.PopFont()
    return result
end

function imgui.ButtonMainMenu(name, size)
	imgui.PushFont(fontsize)
    imgui.PushStyleColor(imgui.Col.Button, imgui.Col.WindowBg)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.Col.WindowBg)
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.Col.WindowBg)
	
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.20, 0.25, 0.29, 1.00))

    if not size then size = imgui.ImVec2(0, 0) end
    local result = imgui.Button(name, size)
    imgui.PopStyleColor(4)
	imgui.PopFont()
    return result
end

rrpServers = {
	'62.122.214.40',
	'46.174.53.218',
	'46.174.53.214',
	'62.122.213.28',
	'176.32.37.14'
}
function checkServer(ip)
	for k, v in pairs(rrpServers) do
		if v == ip then 
			return true
		end
	end
	return false
end

function addLeaderMessage(message, color)
	color = color or bbc
	sampAddChatMessage(tag .. message, color)
end

function addmsg(message, color)
	color = color or bbc
	sampAddChatMessage(tag .. message, color)
end

function checkUpdate()
	local dlstatus = require('moonloader').download_status
		
	  local fpath = os.getenv('TEMP') .. '\\version-ltools.json'
	  
	  downloadUrlToFile('https://raw.githubusercontent.com/hellogoodbuy/LTools/main/checkVersion.json', fpath, function(id, status, p1, p2) 
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
		local f = io.open(fpath, 'r') 
		if f then
		  local info = decodeJson(f:read('*a')) 
		  updatelink = info.updateurl
		  if info and info.latest then
			version = tonumber(info.latest) 
			if version > tonumber(thisScript().version) then 
				lua_thread.create(function ()
				addLeaderMessage('Обнаружено новое обновление : ' .. version .. '. Начинаю загрузку.')
				wait(300)
				
				downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) 
				  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
				  addLeaderMessage('Новое обновление скачано.')
				  thisScript():reload()
				end
				end)
				
				end) 
			else 
			  update = false 
			  addLeaderMessage('У вас установлена актуальная версия : ' .. thisScript().version .. '.')
			end
		  end
		end
	  end
	end)
end

function apply_custom_style()
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2

    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 10.0
    style.FramePadding = ImVec2(5, 5)
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 15.0
    style.GrabMinSize = 15.0
    style.GrabRounding = 7.0
    style.ChildWindowRounding = 8.0
    style.FrameRounding = 6.0
  

      colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
      colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
      colors[clr.WindowBg] = ImVec4(0.86, 0.86, 0.86, 1.00)
      colors[clr.ChildWindowBg] = ImVec4(0.93, 0.93, 0.93, 1.00)
      colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
      colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
      colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
      colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
      colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
      colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
      colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
      colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
      colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
      colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
      colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
      colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
      colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
      colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
      colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
      colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
      colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
      colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
      colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
      colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
      colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
      colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
      colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
      colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
      colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
      colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
      colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
      colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
      colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
apply_custom_style()
