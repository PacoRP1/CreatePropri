Cfg_Property.openViewMenu = function(pK,pV)
    RMenu.Add("nProperty_View", "main_menu", RageUI.CreateMenu("Propriété","INTÉRACTIONS"))
    RMenu:Get("nProperty_View", "main_menu").Closed = function()
        Cfg_Property.main_Menu.viewMenuIsOpen = false 
    end
    if Cfg_Property.main_Menu.viewMenuIsOpen then
        RageUI.CloseAll()
        Cfg_Property.main_Menu.viewMenuIsOpen = false
    else
        Cfg_Property.main_Menu.viewMenuIsOpen = true
        RageUI.Visible(RMenu:Get("nProperty_View", "main_menu"), true)
        Citizen.CreateThread(function()
            Cfg_Property.changeColorIndex()
            while Cfg_Property.main_Menu.viewMenuIsOpen do
                Citizen.Wait(0)
                RageUI.IsVisible(RMenu:Get("nProperty_View", "main_menu"), function()
                    if Cfg_Property.main_Menu.Colors ~= nil then
                        RageUI.Separator("↓ "..Cfg_Property.main_Menu.Colors[Cfg_Property.main_Menu.MainColors].."Information(s) ~s~↓")
                        RageUI.Separator("Nom de la propriété : ~b~"..pV.label)
                        RageUI.Separator("Prix de la propriété : ~b~"..pV.price.."$")
                        RageUI.Separator("Capacité du coffre : ~b~"..pV.stockCapacity.."~s~ - KG")
                        RageUI.Separator("Capacité du garage : ~b~"..pV.gPlaces.."~s~ - places")
                        RageUI.Separator("↓ "..Cfg_Property.main_Menu.ColorsTwo[Cfg_Property.main_Menu.MainColors].."Intéraction(s) ~s~↓")
                        RageUI.Button("Visiter la propriété", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                RageUI.CloseAll()
                                Cfg_Property.main_Menu.viewMenuIsOpen = false
                                Cfg_Property.onPropertyVisite(pK,pV)
                            end,
                        })
                    end
                end)
            end
        end)
    end
end

Cfg_Property.onPropertyVisite = function(pK,pV)
    Citizen.CreateThread(function()
        Cfg_Property.ServerSide(Cfg_Property.Prefix..":SetPlayerInBucket", (100+tonumber(pV.propertyID)))
        local actualityP = Cfg_Property.main_Menu.propertyList[tonumber(pV.pNumber)]
        Cfg_Property.main_Menu.onVisiting = true
        Cfg_Property.main_Menu.lastPos = GetEntityCoords(PlayerPedId())
        SetEntityCoords(PlayerPedId(), actualityP.interiorEntry.pos, false, false, false, false)
        SetEntityHeading(PlayerPedId(), actualityP.interiorEntry.heading)
        while Cfg_Property.main_Menu.onVisiting do
            Citizen.Wait(0)
            local onVisisteDistance = {}
            onVisisteDistance["pExit"] = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), actualityP.interiorExit.pos, true)
            if onVisisteDistance["pExit"] < 10.0 then
                DrawMarker(22, actualityP.interiorExit.pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, actualityP.interiorExit.colorsMarker.r, actualityP.interiorExit.colorsMarker.g, actualityP.interiorExit.colorsMarker.b, 255, 55555, false, true, 2, false, false, false, false)
                if onVisisteDistance["pExit"] < 1.2 then
                    Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour sortir de la propriété")
                    if IsControlJustPressed(0, 38) then
                        Cfg_Property.main_Menu.onVisiting = false
                    end
                end
            end
        end
        Cfg_Property.ServerSide(Cfg_Property.Prefix..":SetPlayerInBucket", 0)
        SetEntityCoords(PlayerPedId(), Cfg_Property.main_Menu.lastPos, false, false, false, false)
        actualityP = nil
    end)
end