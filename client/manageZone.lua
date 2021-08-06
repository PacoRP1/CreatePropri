Cfg_Property.LoadActualityProperty = function(identifier)
    Citizen.CreateThread(function()
        while Cfg_Property.ESXLoaded == nil do
            Cfg_Property.InSide(Cfg_Property.ESXEvent, function(esxEvent) Cfg_Property.ESXLoaded = esxEvent end)
            Citizen.Wait(0)
        end
        while true do
            local interactWait = 750
            for k,v in pairs(Cfg_Property.ActualityProperty) do
                if v.owner == nil then
                    local visitePropertyDistance = {}
                    visitePropertyDistance["pEnter"] = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z, true)
                    if visitePropertyDistance["pEnter"]  < 10.0 then
                        interactWait = 1
                        DrawMarker(22, json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
                        if visitePropertyDistance["pEnter"] < 1.5 then
                            Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour intéragir avec la propriété")
                            if IsControlJustPressed(0, 38) then
                                Cfg_Property.openViewMenu(k,v)
                            end
                        end
                    end
                else
                    if v.owner == identifier or Cfg_Property.hasAcess[v.propertyID] then
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z, true) < 10.0 then
                            interactWait = 1
                            DrawMarker(22, json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
                            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z, true) < 1.5 then
                                Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour intéragir avec votre propriété ~b~"..v.label)
                                if IsControlJustPressed(0, 38) then
                                    Cfg_Property.openPropertyMenu(k,v)
                                end
                            end
                        elseif GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), json.decode(v.gEnterPos).x, json.decode(v.gEnterPos).y, json.decode(v.gEnterPos).z, true) < 15.0 then
                            interactWait = 1
                            DrawMarker(22, json.decode(v.gEnterPos).x, json.decode(v.gEnterPos).y, json.decode(v.gEnterPos).z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
                            if IsPedInAnyVehicle(PlayerPedId(), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() then   
                                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), json.decode(v.gEnterPos).x, json.decode(v.gEnterPos).y, json.decode(v.gEnterPos).z, true) < 7.5 then
                                    Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour ranger le véhicule dans votre garage")
                                    if IsControlJustPressed(0, 38) then
                                        if (tonumber(v.gPlaces) - #json.decode(v.pVehicules)) <= 0 then
                                            Cfg_Property.Popup("Votre garage ne contient pas d'emplacement libre pour stocker ce véhicule !")
                                        else
                                            Cfg_Property.ServerSide(Cfg_Property.Prefix..":addVehiculeInProperty", GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)), Cfg_Property.ESXLoaded.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false)), v.propertyID)
                                            DeleteEntity(GetVehiclePedIsIn(PlayerPedId(), false))
                                        end
                                    end
                                end
                            else
                                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), json.decode(v.gEnterPos).x, json.decode(v.gEnterPos).y, json.decode(v.gEnterPos).z, true) < 1.5 then
                                    Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour intéragir avec votre garage")
                                    if IsControlJustPressed(0, 38) then
                                        Cfg_Property.ServerSide(Cfg_Property.Prefix..":SetPlayerInBucket", (100+tonumber(v.propertyID)))
                                        local crtVehicule = {}
                                        Cfg_Property.inGarage = true
                                        Cfg_Property.lastPostion = GetEntityCoords(PlayerPedId())
                                        DoScreenFadeOut(750)
                                        while not IsScreenFadedOut() do Wait(0) end
                                        SetEntityCoords(PlayerPedId(), Cfg_Property.garageInteriorsInfos[tonumber(v.gPlaces)].tpPos)
                                        for vehiculeID,vehicule in pairs(json.decode(v.pVehicules)) do
                                            RequestModel(vehicule.props.model)
                                            while not HasModelLoaded(vehicule.props.model) do
                                                Wait(1)
                                            end
                                            local vehicle = CreateVehicle(vehicule.props.model, Cfg_Property.garageInteriorsInfos[tonumber(v.gPlaces)].vehiculeSpawner[vehiculeID].pos, Cfg_Property.garageInteriorsInfos[tonumber(v.gPlaces)].vehiculeSpawner[vehiculeID].heading, false, false)
                                            Cfg_Property.ESXLoaded.Game.SetVehicleProperties(vehicle, vehicule.props)
                                            SetVehicleUndriveable(vehicle, true)
                                            crtVehicule[vehiculeID] = vehicle
                                        end
                                        DoScreenFadeIn(1500)
                                        while Cfg_Property.inGarage do
                                            Citizen.Wait(0)                 
                                            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Cfg_Property.garageInteriorsInfos[tonumber(v.gPlaces)].tpExit, true) < 10.0 then
                                                DrawMarker(22, Cfg_Property.garageInteriorsInfos[tonumber(v.gPlaces)].tpExit, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 255 ,0, 255, 55555, false, true, 2, false, false, false, false)
                                                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Cfg_Property.garageInteriorsInfos[tonumber(v.gPlaces)].tpExit, true) < 1.5 then
                                                    Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour sortir de votre garage")
                                                    if IsControlJustPressed(0, 38) then
                                                        DoScreenFadeOut(750)
                                                        while not IsScreenFadedOut() do Wait(0) end
                                                        DoScreenFadeIn(800)
                                                        SetEntityCoords(PlayerPedId(), Cfg_Property.lastPostion, false, false, false, false)
                                                        Cfg_Property.inGarage = false
                                                    end
                                                end
                                            end
                                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                                Cfg_Property.HelpNotif("Appuyez sur ~INPUT_FRONTEND_RDOWN~ pour sortir le véhicule du garage")
                                                if IsControlJustPressed(0, 191) then
                                                    local props = Cfg_Property.ESXLoaded.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId()))
                                                    for vehiculeID,vehicule in pairs(json.decode(v.pVehicules)) do
                                                        if props.plate == vehicule.props.plate then
                                                            Cfg_Property.ServerSide(Cfg_Property.Prefix..":outVehiculeFromProperty", v.propertyID, vehiculeID)
                                                            Cfg_Property.inGarage = false
                                                            Citizen.CreateThread(function()
                                                                DoScreenFadeOut(750)
                                                                while not IsScreenFadedOut() do Wait(0) end
                                                                DoScreenFadeIn(800)
                                                                RequestModel(props.model)
                                                                while not HasModelLoaded(props.model) do Wait(1) end
                                                                SetEntityCoords(PlayerPedId(), Cfg_Property.lastPostion, false, false, false, false)
                                                                local vehicle = CreateVehicle(props.model, GetEntityCoords(PlayerPedId()), 10, true, true)
                                                                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                                                Cfg_Property.ESXLoaded.Game.SetVehicleProperties(vehicle, props)
                                                            end)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        Citizen.SetTimeout(1200, function()
                                            for k,v in pairs(crtVehicule) do
                                                if DoesEntityExist(v) then
                                                    DeleteEntity(v)
                                                end
                                            end
                                        end)
                                        Cfg_Property.ServerSide(Cfg_Property.Prefix..":SetPlayerInBucket", 0)
                                    end
                                end
                            end
                        end
                    else
                        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z, true) < 10.0 then
                            interactWait = 1
                            DrawMarker(22, json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
                            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z, true) < 1.5 then
                                Cfg_Property.HelpNotif("Appuyez sur ~INPUT_CONTEXT~ pour sonner à la propriété : ~b~"..v.label)
                                if IsControlJustPressed(0, 38) then
                                    if not hasCloched then
                                        hasCloched = true
                                        Cfg_Property.Popup("Vous sonner à la proprété : ~b~"..v.label)
                                        Cfg_Property.ServerSide(Cfg_Property.Prefix..":clochInProperty", v.propertyID, v.pNumber)
                                        Citizen.SetTimeout(7500, function()
                                            hasCloched = false
                                        end)
                                    else
                                        Cfg_Property.Popup("~r~Veuillez patienter avant de re-sonner !")
                                    end
                                end
                            end
                        end
                    end
                end
            end
            Citizen.Wait(interactWait)
        end
    end)
end