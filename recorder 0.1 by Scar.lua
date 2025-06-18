local ev = require("lib.samp.events")
local imgui = require("mimgui")
local vk = require("vkeys")
local ffi = require ("ffi")
local inicfg = require("inicfg")
local encoding = require("encoding")
local directIni = 'moonloader\\config\\Recorder by Scar.ini'
local mainIni = inicfg.load(nil, directIni)
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local tick, routes, errors = 0, 0, 0


local rec = {
    menu = new.bool(),
    addMenu = new.bool(),
    stat = new.bool(),
    settings = {
        recDelay = new.float(80),
        radius_check_pos = new.float(5.0)
    },
    add = {
        Name = new.char[256]()
    }
}

function main()
    repeat wait(0) until isSampAvailable()

    if not doesFileExist('moonloader\\config\\Recorder by Scar.ini') then
        file1 = io.open('moonloader\\config\\Recorder by Scar.ini', 'a')
            for i = 1, 50 do
                file1:write('[' .. i ..  ']\nNameRoute=\nroutes=0\n')
            end
        file1:close()
    end

    sampRegisterChatCommand("rc", function()
        rec.menu[0] = not rec.menu[0]
    end)
    while true do wait(0)

        if mainIni[1].routes < 0 then mainIni[1].routes = 0 end

        if record then
            if drive ~= nil then
                if isCharInAnyCar(PLAYER_PED) then
                    local file = open_file('w')
                    if file then
                        repeat
                            wait(0)
                            local time = os.clock() * 1000
                            if time - tick > tonumber(rec.settings.recDelay[0]) then
                                if isCharInAnyCar(PLAYER_PED) then
                                    local car = storeCarCharIsInNoSave(PLAYER_PED)
                                    local posX, posY, _ = getCarCoordinates(car)
                                    local speed = getCarSpeed(car)
                                    file:write('{'..posX..'}:{'..posY..'}:{'..speed..'}\n')
                                else
                                    break
                                end
                                tick = os.clock() * 1000
                            end
                        until (record_stop == true)
                        file:close()
                        sampAddChatMessage("Запись закончена.", -1)
                    end
                end
            end
        end

        if play then
            if isCharInAnyCar(PLAYER_PED) then
                if drive ~= nil then
                    local data = read_route()
                    if data then
                        for key, value in pairs(data) do
                            local posX, posY, Speed = value:match('{(.*)}:{(.*)}:{(.*)}')
                            if posX and posY and Speed then
                                repeat
                                    wait(0)
                                    draw_line(tonumber(posX), tonumber(posY))
                                    local veh = storeCarCharIsInNoSave(PLAYER_PED)
                                    if key % 2 > 0 then
                                        local carPosX, carPosY, carPosZ = getCarCoordinates(veh)
                                        LeftorRight(tonumber(posX), tonumber(posY), carPosX, carPosY, veh)
                                        if getCarSpeed(veh) < Speed + 0.2 then
                                            writeMemory(0xB73458 + 0x20, 1, 255, false)
                                        else
                                            writeMemory(0xB73458 + 0xC, 1, 255, false)
                                        end
                                    else
                                        break
                                    end
                                until locateCharInCar2d(PLAYER_PED, tonumber(posX), tonumber(posY), rec.settings.radius_check_pos[0], rec.settings.radius_check_pos[0], false) 
                                if stop then
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

    end
end

local newFrame = imgui.OnFrame(     ---------------------- Основное меню
    function() return rec.menu[0] end,
    function(player)

        local sizeX, sizeY = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"Recorder v0.1", rec.menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

            imgui.BeginChild("##Child1", imgui.ImVec2(260, 362), true)

                imgui.CenterText(u8"Маршруты", imgui.SetCursorPosY(6))
                imgui.Separator()

                for i = 1, 50 do
                    if imgui.Selectable(u8"Маршрут №"..i..": "..mainIni[i].NameRoute..'\n', false) then
                        drive = mainIni[i].NameRoute
                        drive_del = i
                    end
                    if i ~= 50 then
                        imgui.Separator()
                    end
                end

            imgui.EndChild()

            imgui.SameLine()

            imgui.BeginChild("##Child2", imgui.ImVec2(316, 362), true)

                imgui.CenterText(u8"Настройки", imgui.SetCursorPosY(6))
                imgui.Separator()
                imgui.Text(u8"Задержка записи: Стандарт - 80")
                imgui.PushItemWidth(300)
                imgui.SliderFloat("##Slider1", rec.settings.recDelay, 40, 300) imgui.PopItemWidth()
                imgui.NewLine()
                imgui.Text(u8"Радиус подбора координат: Стандарт - 5.0")
                imgui.PushItemWidth(300)
                imgui.SliderFloat("##Slider2", rec.settings.radius_check_pos, 3, 16) imgui.PopItemWidth()
                
                imgui.NewLine()
                imgui.Separator()
                imgui.NewLine()

                if imgui.Button(u8"Запись", imgui.ImVec2(300, 24)) then
                    if isCharInAnyCar(PLAYER_PED) then
                        if drive ~= nil then
                            rec.stat[0] = true
                            record_stop = false
                            record = true
                        else
                            sampAddChatMessage("Маршрут не выбран.", -1)
                        end
                    else
                        sampAddChatMessage("Вы не в машине.", -1)
                    end
                end

                if imgui.Button(u8"Стоп ", imgui.ImVec2(300, 24)) then
                    if isCharInAnyCar(PLAYER_PED) then
                        if drive ~= nil then
                            rec.stat[0] = false
                            record = false
                            record_stop = true
                        else
                            sampAddChatMessage("Маршрут не выбран.", -1)
                        end
                    else
                        sampAddChatMessage("Вы не в машине.", -1)
                    end
                end

                if imgui.Button(u8"Старт", imgui.ImVec2(146, 24)) then
                    if isCharInAnyCar(PLAYER_PED) then
                        if drive ~= nil then
                            rec.stat[0] = true
                            stop = false
                            play = true
                        else
                            sampAddChatMessage("Маршрут не выбран.", -1)
                        end
                    else
                        sampAddChatMessage("Вы не в машине.", -1)
                    end
                end

                imgui.SameLine()

                if imgui.Button(u8"Стоп", imgui.ImVec2(146, 24)) then
                    if isCharInAnyCar(PLAYER_PED) then
                        if drive ~= nil and play then
                            rec.stat[0] = false
                            stop = true
                            play = false
                        else
                            sampAddChatMessage("Маршрут не выбран.", -1)
                        end
                    else
                        sampAddChatMessage("Вы не в машине.", -1)
                    end
                end

                imgui.NewLine()

                if imgui.Button(u8"Добавить маршрут", imgui.ImVec2(300, 24)) then
                    rec.addMenu[0] = not rec.addMenu[0]
                end
                if imgui.Button(u8"Удалить маршрут", imgui.ImVec2(300, 24)) then
                    if drive ~= nil then
                        routes = routes - 1
                        for i = 1, 50 do
                            if drive_del == i then
                                mainIni[i].NameRoute = ''
                                mainIni[i].routes = routes
                                inicfg.save(mainIni, directIni)
                                os.remove("moonloader\\recorder\\rec_"..u8:decode(drive)..".txt")
                                sampAddChatMessage('Маршрут был удалён!', -1)
                                break
                            end
                        end
                    else
                        sampAddChatMessage("Выберите маршрут чтобы удалить.", -1)
                    end
                end

                imgui.NewLine()

            imgui.EndChild()

            imgui.PushFont(font16)
            imgui.TextColoredRGB("{FF5F5F}Скрипт от Scar", imgui.SetCursorPos(imgui.ImVec2(386, 366)))
            imgui.PopFont()

        imgui.End()

    end
)

local newFrame1 = imgui.OnFrame(     ---------------------- Добавление Маршрута
    function() return rec.addMenu[0] end,
    function(player)

        local sizeX, sizeY = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(200, 126), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"Создание нового маршрута", rec.addMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

            imgui.Text(u8"Название маршрута: ")
            imgui.PushItemWidth(184)
            imgui.InputText(u8"##Input1", rec.add.Name, sizeof(rec.add.Name)-1)
            imgui.PopItemWidth()

            if errors == 0 then
                imgui.NewLine()
            elseif errors == 1 then
                imgui.CenterText(u8'Сохранено максимальное количество маршрутов.')
            end

            if imgui.Button(u8"Добавить", imgui.ImVec2(184, 24)) then
                if routes == 50 then
                    errors = 1
                elseif rec.add.Name[0] ~= nil then
                    for i = 1, 50, 1 do
                        if mainIni[i].NameRoute == '' then
                            sampAddChatMessage("[Recorder] - Был добавлен новый маршрут в список: [ "..u8:decode(str(rec.add.Name)).." ]", -1)
                            errors = 0
                            routes = routes + 1
                            mainIni[i].NameRoute = str(rec.add.Name)
                            mainIni[i].routes = routes
                            inicfg.save(mainIni, directIni)
                            rec.addMenu[0] = false
                            imgui.StrCopy(rec.add.Name, '')
                            break
                        end
                    end
                end
            end
        imgui.End()
    end
)

local newFrame2 = imgui.OnFrame(    ---------------------- Статистика
    function() return rec.stat[0] end,
    function(player)

        local x, y, z = getCharCoordinates(PLAYER_PED)

        player.HideCursor = true

        local sizeX, sizeY = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY - 120), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(420, 80), imgui.Cond.FirstUseEver)

        imgui.Begin(u8"##Stat", rec.stat, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)

            imgui.BeginChild("##Child", imgui.ImVec2(404, 60), true)
                imgui.PushFont(font32) imgui.SetCursorPos(imgui.ImVec2(16, 14))
                imgui.Text(u8"X: ") imgui.SameLine() imgui.TextColoredRGB(u8"{FF0000}".. math.floor(x)..' ') imgui.SameLine()
                imgui.Text(u8"Y: ") imgui.SameLine() imgui.TextColoredRGB(u8"{FF0000}".. math.floor(y)..' ') imgui.SameLine()
                imgui.Text(u8"Speed: ") imgui.SameLine() imgui.TextColoredRGB(u8"{FF0000}".. math.floor(getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED))))
                imgui.PopFont()
            imgui.EndChild()

        imgui.End()

    end
)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    if font32 == nil then
        font32 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arial.ttf', 32.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end

    if font16 == nil then
        font16 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arial.ttf', 16.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end


        style.WindowPadding = ImVec2(8, 8) 
        style.WindowRounding = 8.0
        style.FramePadding = ImVec2(4, 4)
        style.ItemSpacing = ImVec2(4, 4)
        style.ItemInnerSpacing = ImVec2(8, 6)
        style.IndentSpacing = 21
        style.ScrollbarSize = 10
        style.ScrollbarRounding = 8
        style.GrabMinSize = 12
        style.GrabRounding = 3
        style.ChildRounding = 8.0
        style.FrameRounding = 6.0
        style.WindowTitleAlign = ImVec2(0.5, 0.5)
        style.ButtonTextAlign = ImVec2(0.5, 0.5)

       colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
       colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
       colors[clr.WindowBg] = ImVec4(0.14, 0.14, 0.14, 1.00)
       colors[clr.ChildBg] = ImVec4(0.12, 0.12, 0.12, 1.00)
       colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
       colors[clr.Border] = ImVec4(0.14, 0.14, 0.14, 1.00)
       colors[clr.BorderShadow] = ImVec4(1.00, 1.00, 1.00, 0.10)
       colors[clr.FrameBg] = ImVec4(0.22, 0.22, 0.22, 1.00)
       colors[clr.FrameBgHovered] = ImVec4(0.18, 0.18, 0.18, 1.00)
       colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
       colors[clr.TitleBg] = ImVec4(0.14, 0.14, 0.14, 0.81)
       colors[clr.TitleBgCollapsed] = ImVec4(0.14, 0.14, 0.14, 0.81)
       colors[clr.TitleBgActive] = ImVec4(0.14, 0.14, 0.14, 1.00)
       colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
       colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
       colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
       --colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrab] = ImVec4(1.00, 0.28, 0.28, 1.00)
       colors[clr.SliderGrabActive] = ImVec4(1.00, 0.28, 0.28, 1.00)
       colors[clr.Button] = ImVec4(1.00, 0.28, 0.28, 1.00)
       colors[clr.ButtonHovered] = ImVec4(1.00, 0.39, 0.39, 1.00)
       colors[clr.ButtonActive] = ImVec4(1.00, 0.21, 0.21, 1.00)
       colors[clr.Header] = ImVec4(0.12, 0.23, 0.93, 0.71)
       colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
       colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
       colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
       colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
       colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
       --colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
       --colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
       --colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
       colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
       colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
       colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
       colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
       colors[clr.TextSelectedBg] = ImVec4(1.00, 0.28, 0.28, 1.00)
       colors[clr.Separator] = ImVec4(0.43, 0.43, 0.50, 0.50)
       --colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    
end)

function draw_line(posX, posY)
	local chPosX, chPosY, chPosZ = getCharCoordinates(PLAYER_PED)
	if isPointOnScreen(posX, posY, chPosZ, 0.0) then
		local wPosX, wPosY = convert3DCoordsToScreen(posX, posY, chPosZ)
		local wPosX1, wPosY1 = convert3DCoordsToScreen(chPosX, chPosY, chPosZ)
		renderDrawLine(wPosX1, wPosY1, wPosX, wPosY, 2, 0xFF878787)
		renderDrawPolygon(wPosX, wPosY, 10, 10, 14, 0.0, 0xFF640000)
		renderDrawPolygon(wPosX1, wPosY1, 10, 10, 14, 0.0, 0xFF640000)
	end
end

function open_file(mode)
    if not doesDirectoryExist('moonloader/recorder') then
        createDirectory('moonloader/recorder')
    else
        return io.open('moonloader/recorder/rec_'..u8:decode(drive)..'.txt', mode)
    end
end

function read_route()
	local file = open_file('r')
	if file then
		local data = {}
		for line in file:lines() do
			table.insert(data, line)
		end
		file:close()
		return data
	end
end

function LeftorRight(posX, posY, carPosX, carPosY, car)
	local heading = math.rad(getHeadingFromVector2d(posX - carPosX, posY - carPosY) + math.abs(getCarHeading(car) - 360.0))
	local heading = getHeadingFromVector2d(math.deg(math.sin(heading)), math.deg(math.cos(heading)))
	if heading > 180.0 and 355.0 > heading then -- press left
		setGameKeyState(0, -128)
	else
		if heading > 5.0 and 180.0 >= heading then -- press right
			setGameKeyState(0, 128)
		else
			setGameKeyState(0, 0)
		end
	end
end

-- Доп функции imgui:

function imgui.TextColoredRGB(string)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local function color_imvec4(color)
        if color:upper() == 'SSSSSS' then return colors[clr.Text] end
        local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
        local rgb = {}
        for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
        return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
    end
    local function render_text(string)
        local text, color = {}, {}
        local m = 1
        while string:find('{......}') do
            local n, k = string:find('{......}')
            text[#text], text[#text+1] = string:sub(m, n-1), string:sub(k+1, #string)
            color[#color+1] = color_imvec4(string:sub(n+1, k-1))
            local t1, t2 = string:sub(1, n-1), string:sub(k+1, #string)
            string = t1..t2
            m = k-7
        end
        if text[0] then
            for i, _ in ipairs(text) do
                imgui.TextColored(color[i] or colors[clr.Text], u8(text[i]))
                imgui.SameLine(nil, 0)
            end
            imgui.NewLine()
        else imgui.Text(u8(string)) end
    end
    render_text(string)
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
