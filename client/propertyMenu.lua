Cfg_Property.openPropertyMenu = function(pK,pV)
    RMenu.Add("nProperty_Owned", "main_menu", RageUI.CreateMenu("Propriété","INTÉRACTIONS"))
    RMenu:Get("nProperty_Owned", "main_menu").Closed = function()
        Cfg_Property.main_Menu.ownedMenuIsOpen = false 
    end
    if Cfg_Property.main_Menu.ownedMenuIsOpen then
        RageUI.CloseAll()
        Cfg_Property.main_Menu.ownedMenuIsOpen = false
    else
        Cfg_Property.main_Menu.ownedMenuIsOpen = true
        RageUI.Visible(RMenu:Get("nProperty_Owned", "main_menu"), true)
        Citizen.CreateThread(function()
            Cfg_Property.changeColorIndex()
            while Cfg_Property.main_Menu.ownedMenuIsOpen do
                Citizen.Wait(0)
                RageUI.IsVisible(RMenu:Get("nProperty_Owned", "main_menu"), function()
                    if Cfg_Property.main_Menu.Colors ~= nil then
                        RageUI.Separator("↓ "..Cfg_Property.main_Menu.Colors[Cfg_Property.main_Menu.MainColors].."Information(s) ~s~↓")
                        RageUI.Separator("Nom de votre propriété : ~b~"..pV.label)
                        RageUI.Separator("Rue : ~b~"..GetStreetNameFromHashKey(GetStreetNameAtCoord(json.decode(pV.pEnterPos).x,json.decode(pV.pEnterPos).y, json.decode(pV.pEnterPos).z)))
                        RageUI.Separator("Garage : ~b~"..#json.decode(pV.pVehicules).."/"..pV.gPlaces.."~s~ - places disponible")
                        RageUI.Separator("↓ "..Cfg_Property.main_Menu.ColorsTwo[Cfg_Property.main_Menu.MainColors].."Intéraction(s) ~s~↓")
                        RageUI.Button("Entrer dans votre propriété", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                RageUI.CloseAll()
                                Cfg_Property.main_Menu.ownedMenuIsOpen = false
                                Cfg_Property.inPropertyOwned(pK,pV)
                            end,
                        })
                    end
                end)
            end
        end)
    end
end

Cfg_Property.inPropertyOwned = function(pK,pV)
    Citizen.CreateThread(function()
        Cfg_Property.ServerSide(Cfg_Property.Prefix..":enterInProperty", pV.propertyID)
        Cfg_Property.Popup("Vous êtes entrer dans la propriété : ~b~"..pV.label)
        local actualityP = Cfg_Property.main_Menu.propertyList[tonumber(pV.pNumber)]
        Cfg_Property.main_Menu.onVisiting = true
        Cfg_Property.main_Menu.lastPos = GetEntityCoords(PlayerPedId())
        SetEntityCoords(PlayerPedId(), actualityP.interiorEntry.pos, false, false, false, false)
        SetEntityHeading(PlayerPedId(), actualityP.interiorEntry.heading)
        while Cfg_Property.main_Menu.onVisiting do
            Citizen.Wait(0)
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), actualityP.interiorExit.pos, true) < 10.0 then
                DrawMarker(22, actualityP.interiorExit.pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, actualityP.interiorExit.colorsMarker.r, actualityP.interiorExit.colorsMarker.g, actualityP.interiorExit.colorsMarker.b, 255, 55555, false, true, 2, false, false, false, false)
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), actualityP.interiorExit.pos, true) < 1.2 then
                    Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour sortir de votre propriété")
                    if IsControlJustPressed(0, 38) then
                        Cfg_Property.main_Menu.onVisiting = false
                    end
                end
            end 
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), actualityP.pStock.pos, true) < 10.0 then
                DrawMarker(22, actualityP.pStock.pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, actualityP.pStock.colorsMarker.r, actualityP.pStock.colorsMarker.g, actualityP.pStock.colorsMarker.b, 255, 55555, false, true, 2, false, false, false, false)
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), actualityP.pStock.pos, true) < 1.2 then
                    Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour géré votre propriété")
                    if IsControlJustPressed(0, 38) then
                        Cfg_Property.openManageProperty(pK,pV)
                    end
                end          
            end
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), actualityP.pDressing.pos, true) < 10.0 then
                DrawMarker(22, actualityP.pDressing.pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, actualityP.pDressing.colorsMarker.r, actualityP.pDressing.colorsMarker.g, actualityP.pDressing.colorsMarker.b, 255, 55555, false, true, 2, false, false, false, false)
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), actualityP.pDressing.pos, true) < 1.2 then
                    Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour accéder à votre dressing")
                    if IsControlJustPressed(0, 38) then
                        Cfg_Property.openPropertyDressing()
                    end
                end          
            end
        end
        Cfg_Property.ServerSide(Cfg_Property.Prefix..":exitProperty", pV.propertyID)
        Cfg_Property.Popup("Vous êtes sortie de la propriété : ~b~"..pV.label)
        SetEntityCoords(PlayerPedId(), Cfg_Property.main_Menu.lastPos, false, false, false, false)
        actualityP = nil
    end)
end