local LARGE_BTN = Vector2f.new(300, 50)
local SMALL_BTN = Vector2f.new(200, 40)
local WINDOW_WIDTH_M = 300
local WINDOW_WIDTH_S = 150
local LANG = ""
local FONT_NAME = ""
local FONT_SIZE = 24
local FONT_GLYPH = {
    0x0020, 0xFFEE,
    0,
}
local I18N = {
    modName = "Weapon Use Counter Blocker",
    enableModCheckboxTip = "Enable Blocker",
    wpBlockTip = "Select needed to block weapon type (including FIRST & SECOND weapon)",
    longSword = "Great Sword",
    shortSword = "Sword & Shield",
    twinSword = "Dual Blades",
    tachi = "Long Sword",
    hammer = "Hammer",
    whistle = "Hunting Horn",
    lance = "Lance",
    gunLance = "Gunlance",
    slashAxe = "Switch Axe",
    chargeAxe = "Charge Blade",
    rod = "Insect Glaive",
    bow = "Bow",
    hbg = "Heavy Bowgun",
    lbg = "Light Bowgun"
}
local INTER_VERSION = "1.0.0"

local i18nFilePath = ""
local userConfigPath = ""
local config = {
    enableMod = false,
    wpBlockList = {}
}

-- app.WeaponDef.TYPE
local weaponType = {
    invalid = -1,
    longSword = 0,
    shortSword = 1,
    twinSword = 2,
    tachi = 3,
    hammer = 4,
    whistle = 5,
    lance = 6,
    gunLance = 7,
    slashAxe = 8,
    chargeAxe = 9,
    rod = 10,
    bow = 11,
    hbg = 12,
    lbg = 13,
    max = 14
}

local this = nil
local currentQuestType = nil
local currentFirstWp = nil
local currentSecondWp = nil
local currentNum = nil

local enableCheckBoxState = false
local enableCheckBoxChanged = false
local wpLongSwordState = false
local wpLongSwordChanged = false
local wpShortSwordState = false
local wpShortSwordChanged = false
local wpTwinSwordState = false
local wpTwinSwordChanged = false
local wpTachiState = false
local wpTachiChanged = false
local wpHammerState = false
local wpHammerChanged = false
local wpWhistleState = false
local wpWhistleChanged = false
local wpLanceState = false
local wpLanceChanged = false
local wpGunLanceState = false
local wpGunLanceChanged = false
local wpSlashAxeState = false
local wpSlashAxeChanged = false
local wpChargeAxeState = false
local wpChargeAxeChanged = false
local wpRodState = false
local wpRodChanged = false
local wpBowState = false
local wpBowChanged = false
local wpHbgState = false
local wpHbgChanged = false
local wpLbgState = false
local wpLbgChanged = false

local function logger(content)
    print("[" .. I18N.modName .. "] " .. tostring(content))
    log.info("[" .. I18N.modName .. "] " .. tostring(content))
end

local function checkWpTypeInBlockList(wpType)
    local flag = false
    for i = 1, #config.wpBlockList do
        if config.wpBlockList[i] == wpType then
            flag = true
            break
        end
    end
    return flag
end

local function loadI18NConfigJson(jsonPath)
    if json ~= nil then
        local jsonFile = json.load_file(jsonPath)
        if jsonFile then
            I18N = jsonFile
        end
    end
end

local function loadUserConfigJson(jsonPath)
    if json ~= nil then
        local jsonFile = json.load_file(jsonPath)
        if jsonFile then
            config.enableMod = jsonFile.enableMod
            if jsonFile.wpBlockList == nil then
                config.wpBlockList = {}
            else
                config.wpBlockList = jsonFile.wpBlockList
            end
        else
            json.dump_file(jsonPath, config)
        end
    end
end

local function saveUserConfigJson(jsonPath)
    if json ~= nil then
        json.dump_file(jsonPath, config)
    end
end

local function pushToArray(array, value)
    if array == nil then
        array = {}
    end
    local isInFlag = false
    for i = 1, #array do
        if array[i] == value then
            isInFlag = true
            break
        end
    end
    if not isInFlag then
        table.insert(array, value)
    end
    return array
end

local function popFromArray(array, value)
    if array == nil then
        return nil
    end
    local isInFlag = false
    for i = 1, #array do
        if array[i] == value then
            isInFlag = true
            table.remove(array, i)
            break
        end
    end
    if not isInFlag then
        return array
    end
    if #array == 0 then
        return nil
    end
    return array
end

local function ignoreQuestAndWpNumAdd(args)
    this = args[2]                                        -- non-static func
    currentQuestType = sdk.to_int64(args[3]) & 0xFFFFFFFF -- app.MissionTypeList.TYPE (int32)
    currentFirstWp = sdk.to_int64(args[4]) & 0xFFFFFFFF   -- app.WeaponDef.TYPE (#1 Wp, int32)
    currentSecondWp = sdk.to_int64(args[5]) & 0xFFFFFFFF  -- app.WeaponDef.TYPE (#2 Wp, int32)
    currentNum = sdk.to_int64(args[6]) & 0xFFFFFFFF       -- System.Int32

    if config.enableMod and (checkWpTypeInBlockList(currentFirstWp) or checkWpTypeInBlockList(currentSecondWp)) then
        logger("Weapon counter blocked")
        return sdk.PreHookResult.SKIP_ORIGINAL
    else
        logger("Weapon counter NOT blocked")
        return sdk.PreHookResult.CALL_ORIGINAL
    end
end

local function init()
    loadI18NConfigJson(i18nFilePath)
    loadUserConfigJson(userConfigPath)
    enableCheckBoxState = config.enableMod
    for i = 1, #config.wpBlockList do
        -- init weapon checkbox state
        if config.wpBlockList[i] == weaponType.longSword then
            wpLongSwordState = true
        elseif config.wpBlockList[i] == weaponType.shortSword then
            wpShortSwordState = true
        elseif config.wpBlockList[i] == weaponType.twinSword then
            wpTwinSwordState = true
        elseif config.wpBlockList[i] == weaponType.tachi then
            wpTachiState = true
        elseif config.wpBlockList[i] == weaponType.hammer then
            wpHammerState = true
        elseif config.wpBlockList[i] == weaponType.whistle then
            wpWhistleState = true
        elseif config.wpBlockList[i] == weaponType.lance then
            wpLanceState = true
        elseif config.wpBlockList[i] == weaponType.gunLance then
            wpGunLanceState = true
        elseif config.wpBlockList[i] == weaponType.slashAxe then
            wpSlashAxeState = true
        elseif config.wpBlockList[i] == weaponType.chargeAxe then
            wpChargeAxeState = true
        elseif config.wpBlockList[i] == weaponType.rod then
            wpRodState = true
        elseif config.wpBlockList[i] == weaponType.bow then
            wpBowState = true
        elseif config.wpBlockList[i] == weaponType.hbg then
            wpHbgState = true
        elseif config.wpBlockList[i] == weaponType.lbg then
            wpLbgState = true
        end
    end

    logger("MOD INIT")
end

init()

re.on_draw_ui(function()
    if imgui.tree_node(I18N.modName) then
        enableCheckBoxChanged, enableCheckBoxState = imgui.checkbox(I18N.enableModCheckboxTip, enableCheckBoxState)
        if enableCheckBoxChanged then
            config.enableMod = enableCheckBoxState
        end

        imgui.new_line()
        imgui.text(I18N.wpBlockTip)
        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpLongSwordChanged, wpLongSwordState = imgui.checkbox(I18N.longSword, wpLongSwordState)
        if wpLongSwordChanged then
            if wpLongSwordState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.longSword)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.longSword)
            end
            saveUserConfigJson(userConfigPath)
        end
        imgui.same_line()
        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpShortSwordChanged, wpShortSwordState = imgui.checkbox(I18N.shortSword, wpShortSwordState)
        if wpShortSwordChanged then
            if wpShortSwordState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.shortSword)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.shortSword)
            end
            saveUserConfigJson(userConfigPath)
        end

        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpTwinSwordChanged, wpTwinSwordState = imgui.checkbox(I18N.twinSword, wpTwinSwordState)
        if wpTwinSwordChanged then
            if wpTwinSwordState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.twinSword)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.twinSword)
            end
            saveUserConfigJson(userConfigPath)
        end
        imgui.same_line()
        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpTachiChanged, wpTachiState = imgui.checkbox(I18N.tachi, wpTachiState)
        if wpTachiChanged then
            if wpTachiState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.tachi)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.tachi)
            end
            saveUserConfigJson(userConfigPath)
        end

        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpHammerChanged, wpHammerState = imgui.checkbox(I18N.hammer, wpHammerState)
        if wpHammerChanged then
            if wpHammerState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.hammer)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.hammer)
            end
            saveUserConfigJson(userConfigPath)
        end
        imgui.same_line()
        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpWhistleChanged, wpWhistleState = imgui.checkbox(I18N.whistle, wpWhistleState)
        if wpWhistleChanged then
            if wpWhistleState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.whistle)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.whistle)
            end
            saveUserConfigJson(userConfigPath)
        end

        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpLanceChanged, wpLanceState = imgui.checkbox(I18N.lance, wpLanceState)
        if wpLanceChanged then
            if wpLanceState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.lance)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.lance)
            end
            saveUserConfigJson(userConfigPath)
        end
        imgui.same_line()
        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpGunLanceChanged, wpGunLanceState = imgui.checkbox(I18N.gunLance, wpGunLanceState)
        if wpGunLanceChanged then
            if wpGunLanceState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.gunLance)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.gunLance)
            end
            saveUserConfigJson(userConfigPath)
        end

        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpSlashAxeChanged, wpSlashAxeState = imgui.checkbox(I18N.slashAxe, wpSlashAxeState)
        if wpSlashAxeChanged then
            if wpSlashAxeState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.slashAxe)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.slashAxe)
            end
            saveUserConfigJson(userConfigPath)
        end
        imgui.same_line()
        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpChargeAxeChanged, wpChargeAxeState = imgui.checkbox(I18N.chargeAxe, wpChargeAxeState)
        if wpChargeAxeChanged then
            if wpChargeAxeState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.chargeAxe)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.chargeAxe)
            end
            saveUserConfigJson(userConfigPath)
        end

        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpRodChanged, wpRodState = imgui.checkbox(I18N.rod, wpRodState)
        if wpRodChanged then
            if wpRodState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.rod)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.rod)
            end
            saveUserConfigJson(userConfigPath)
        end
        imgui.same_line()
        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpBowChanged, wpBowState = imgui.checkbox(I18N.bow, wpBowState)
        if wpBowChanged then
            if wpBowState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.bow)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.bow)
            end
            saveUserConfigJson(userConfigPath)
        end

        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpHbgChanged, wpHbgState = imgui.checkbox(I18N.hbg, wpHbgState)
        if wpHbgChanged then
            if wpHbgState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.hbg)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.hbg)
            end
            saveUserConfigJson(userConfigPath)
        end
        imgui.same_line()
        imgui.set_next_item_width(WINDOW_WIDTH_S)
        wpLbgChanged, wpLbgState = imgui.checkbox(I18N.lbg, wpLbgState)
        if wpLbgChanged then
            if wpLbgState then
                config.wpBlockList = pushToArray(config.wpBlockList, weaponType.lbg)
            else
                config.wpBlockList = popFromArray(config.wpBlockList, weaponType.lbg)
            end
            saveUserConfigJson(userConfigPath)
        end

        imgui.tree_pop()
    end
end)

sdk.hook(sdk.find_type_definition("app.savedata.cHunterProfileParam"):get_method(
        "addQuestClearNum(app.MissionTypeList.TYPE, app.WeaponDef.TYPE, app.WeaponDef.TYPE, System.Int32)"),
    ignoreQuestAndWpNumAdd, nil)
