Citizen.CreateThread(function()
    Cfg_Property.prt(Cfg_Property.Credit)
    while Cfg_Property.ESXLoaded == nil do
		Cfg_Property.InSide(Cfg_Property.ESXEvent, function(esxEvent) Cfg_Property.ESXLoaded = esxEvent end)
        Citizen.Wait(0)
        while Cfg_Property.ESXLoaded.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
        Cfg_Property.ESXLoaded.PlayerData = Cfg_Property.ESXLoaded.GetPlayerData()
    end
    RegisterNetEvent("esx:setJob")
    AddEventHandler("esx:setJob", function(job)
        Cfg_Property.ESXLoaded.PlayerData.job = job
    end)

    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler("esx:playerLoaded", function(xPlayer)
        Cfg_Property.ESXLoaded.PlayerData = xPlayer
    end)
    Cfg_Property.pIdentifier = nil
    Cfg_Property.ServerSide(Cfg_Property.Prefix..":requestProperty")
    RegisterNetEvent(Cfg_Property.Prefix..":requestProperty")
    AddEventHandler(Cfg_Property.Prefix..":requestProperty", function(Property, identifier)
        Cfg_Property.ActualityProperty = Property
        if identifier ~= nil then
            Cfg_Property.pIdentifier = identifier
        end
        Cfg_Property.hasAcess = {}
        for k,v in pairs(Property) do
            for k2,v2 in pairs(json.decode(v.pKeys)) do
                if Cfg_Property.pIdentifier == k2 then
                    Cfg_Property.hasAcess[v.propertyID] = true
                end
            end
        end
        if Cfg_Property.BlipsHouse ~= nil then
            for k,v in pairs(Cfg_Property.BlipsHouse) do RemoveBlip(v) end
        end
        Cfg_Property.BlipsHouse = {}
        for k,v in pairs(Cfg_Property.ActualityProperty) do
            if v.owner == nil then
                local Blips = AddBlipForCoord(json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z)
                SetBlipSprite(Blips, 374)
                SetBlipDisplay(Blips, 4)
                SetBlipScale(Blips, 0.5)
                SetBlipColour(Blips, 0)
                SetBlipAsShortRange(Blips, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Propriété non acheté")
                EndTextCommandSetBlipName(Blips)
                Cfg_Property.BlipsHouse[k] = Blips
            elseif v.owner == Cfg_Property.pIdentifier or Cfg_Property.hasAcess[v.propertyID] then
                local ownerBlips = AddBlipForCoord(json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y, json.decode(v.pEnterPos).z)
                SetBlipSprite(ownerBlips, 374)
                SetBlipDisplay(ownerBlips, 4)
                SetBlipScale(ownerBlips, 0.5)
                SetBlipColour(ownerBlips, 0)
                SetBlipAsShortRange(ownerBlips, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Propriété : "..v.label)
                EndTextCommandSetBlipName(ownerBlips)
                Cfg_Property.BlipsHouse[k] =  ownerBlips
            end
        end
    end)
    while Cfg_Property.pIdentifier == nil do Citizen.Wait(0) end
    Cfg_Property.LoadActualityProperty(Cfg_Property.pIdentifier)
    RegisterNetEvent(Cfg_Property.Prefix..":openMainMenu")
    AddEventHandler(Cfg_Property.Prefix..":openMainMenu", function(vInfos, vPlate, pInventory, vWeight)
        RMenu.Add("nProperty_Main", "main_menu", RageUI.CreateMenu("Agence immobilière","INTÉRACTIONS"))
        RMenu:Get("nProperty_Main", "main_menu").Closed = function()
            Cfg_Property.main_Menu.menuIsOpen = false 
        end
        if Cfg_Property.main_Menu.menuIsOpen then
            RageUI.CloseAll()
            Cfg_Property.main_Menu.menuIsOpen = false
        else
            Cfg_Property.main_Menu.menuIsOpen = true
            RageUI.Visible(RMenu:Get("nProperty_Main", "main_menu"), true)
            Citizen.CreateThread(function()
                Cfg_Property.changeColorIndex()
                while Cfg_Property.main_Menu.menuIsOpen do
                    Citizen.Wait(0)
                    RageUI.IsVisible(RMenu:Get("nProperty_Main", "main_menu"), function()
                        if Cfg_Property.main_Menu.Colors ~= nil then
                            RageUI.List("Trier", {"Création d'une propriété", "Propriété créer"}, Cfg_Property.main_Menu.trIndex, nil, {}, true, {
                                onListChange = function(Index, Items)
                                    Cfg_Property.main_Menu.trIndex = Index
                                end,
                                onSelected = function()
                                end,
                            })
                            if Cfg_Property.main_Menu.trIndex == 1 then
                                RageUI.Separator("↓ "..Cfg_Property.main_Menu.Colors[Cfg_Property.main_Menu.MainColors].."Création d'une propriété ~s~↓")
                                RageUI.Button("Nom de la propriété", nil, {RightLabel = Cfg_Property.main_Menu.createdProperty.label or "→→"}, true, {
                                    onSelected = function()
                                        local r = Cfg_Property.Keyboard()
                                        if r ~= nil then
                                            Cfg_Property.main_Menu.createdProperty.label = r
                                        else
                                            Cfg_Property.Popup("~r~Veuillez saisir un champ valide !")
                                        end
                                    end
                                })
                                RageUI.Button("Prix de la propriété", nil, {RightLabel = Cfg_Property.convertValue(Cfg_Property.main_Menu.createdProperty.price, "$") or "→→"}, true, {
                                    onSelected = function()
                                        local p = Cfg_Property.Keyboard()
                                        if p ~= nil then
                                            if tonumber(p) ~= nil then
                                                Cfg_Property.main_Menu.createdProperty.price = p
                                            else
                                                Cfg_Property.Popup("~r~Veuillez saisir un champ valide !")
                                            end
                                        else
                                            Cfg_Property.Popup("~r~Veuillez saisir un champ valide !")
                                        end
                                    end
                                })
                                RageUI.Button("Définir l'entré de la propriété", nil, {RightLabel = "→→"}, true, {
                                    onSelected = function()
                                        Cfg_Property.main_Menu.createdProperty.pEnterPos = GetEntityCoords(PlayerPedId())
                                        Cfg_Property.main_Menu.markersPreview["pEnter"] = {pos = Cfg_Property.main_Menu.createdProperty.pEnterPos, message = "~b~TYPE D'INTÉRACTION~s~\n- Point d'entré de la propriété"}
                                    end
                                })
                                RageUI.Button("Définir l'entré du garage", nil, {RightLabel = "→→"}, true, {
                                    onSelected = function()
                                        Cfg_Property.main_Menu.createdProperty.gEnterPos = GetEntityCoords(PlayerPedId())
                                        Cfg_Property.main_Menu.markersPreview["gEnter"] = {pos = Cfg_Property.main_Menu.createdProperty.gEnterPos, message = "~b~TYPE D'INTÉRACTION~s~\n- Point d'entré du garage"}
                                    end
                                })
                                if not Cfg_Property.main_Menu.onVisiting then
                                    RageUI.List("Intérieur", Cfg_Property.main_Menu.propertyList, Cfg_Property.main_Menu.intIndex, "Appuyez sur [ENTRER] pour visiter la propriété.", {}, true, {
                                        onListChange = function(Index, Items)
                                            Cfg_Property.main_Menu.intIndex = Index
                                            Cfg_Property.main_Menu.createdProperty.pNumber = Cfg_Property.main_Menu.intIndex
                                        end,
                                        onSelected = function()
                                            Cfg_Property.main_Menu.onVisiting = true
                                            Cfg_Property.main_Menu.lastPos = GetEntityCoords(PlayerPedId())
                                            SetEntityCoords(PlayerPedId(), Cfg_Property.main_Menu.propertyList[Cfg_Property.main_Menu.intIndex].interiorEntry.pos, false, false, false, false)
                                            SetEntityHeading(PlayerPedId(), Cfg_Property.main_Menu.propertyList[Cfg_Property.main_Menu.intIndex].interiorEntry.heading)
                                            Cfg_Property.main_Menu.createdProperty.pNumber = Cfg_Property.main_Menu.intIndex
                                        end
                                    })
                                else
                                    RageUI.Button(Cfg_Property.main_Menu.Colors[Cfg_Property.main_Menu.MainColors].."Quitter la visite de la propriété", nil, {RightLabel = "→→"}, true, {
                                        onSelected = function()
                                            SetEntityCoords(PlayerPedId(), Cfg_Property.main_Menu.lastPos, false, false, false, false)
                                            Cfg_Property.main_Menu.onVisiting = false
                                        end
                                    })
                                end
                                RageUI.List("Nombre de places dans le garage", Cfg_Property.main_Menu.garagePlacesList, Cfg_Property.main_Menu.gIndex, nil, {}, true, {
                                    onListChange = function(Index, Items)
                                        Cfg_Property.main_Menu.gIndex = Index
                                        Cfg_Property.main_Menu.createdProperty.gPlaces = Cfg_Property.main_Menu.garagePlacesList[Cfg_Property.main_Menu.gIndex]
                                    end,
                                    onSelected = function()
                                    end
                                })
                                RageUI.List("Capacité du coffre (KG)", Cfg_Property.main_Menu.capacityList, Cfg_Property.main_Menu.stockIndex, nil, {}, true, {
                                    onListChange = function(Index, Items)
                                        Cfg_Property.main_Menu.stockIndex = Index
                                        Cfg_Property.main_Menu.createdProperty.stockCapacity = Cfg_Property.main_Menu.capacityList[Cfg_Property.main_Menu.stockIndex]
                                    end,
                                    onSelected = function()
                                    end
                                })
                                RageUI.Checkbox("Préviualiser les points d'intéraction", nil, Cfg_Property.main_Menu.viewMarkers, {}, {
                                    onChecked = function()
                                        Cfg_Property.main_Menu.viewMarkers = true
                                        Cfg_Property.viewMakers()
                                    end,
                                    onUnChecked = function()
                                        Cfg_Property.main_Menu.viewMarkers = false
                                    end
                                })
                                RageUI.Separator("↓ "..Cfg_Property.main_Menu.ColorsTwo[Cfg_Property.main_Menu.MainColors].."Confirmation la création ~s~↓")
                                RageUI.Button("Valider et sauvegarder", nil, {RightLabel = "→→"}, Cfg_Property.canCreateProperty(), {
                                    onSelected = function()
                                        Cfg_Property.ServerSide(Cfg_Property.Prefix..":createProperty", Cfg_Property.main_Menu.createdProperty)
                                        Cfg_Property.main_Menu.createdProperty = {
                                            pNumber = 1,
                                            gPlaces = 2,
                                            stockCapacity = 50,
                                        }
                                        if Cfg_Property.main_Menu.onVisiting then
                                            SetEntityCoords(PlayerPedId(), Cfg_Property.main_Menu.lastPos, false, false, false, false)
                                            Cfg_Property.main_Menu.onVisiting = false
                                        end
                                        Cfg_Property.main_Menu.viewMarkers = false
                                        Cfg_Property.main_Menu.trIndex = 1
                                        Cfg_Property.main_Menu.intIndex = 1
                                        Cfg_Property.main_Menu.gIndex = 1
                                        Cfg_Property.main_Menu.stockIndex = 1
                                        Cfg_Property.Popup("Votre propriété a été créer avec ~g~succès~s~ !")
                                    end
                                })
                            else
                                local pCount = 0
                                if pCount > 0 then
                                    RageUI.Separator("↓ "..Cfg_Property.main_Menu.Colors[Cfg_Property.main_Menu.MainColors].."Liste des propriétes créer ~s~↓")
                                end
                                for k,v in pairs(Cfg_Property.ActualityProperty) do
                                    if v.owner == nil then
                                        pCount = pCount+1
                                        RageUI.List("[~b~"..k.."~s~] - "..v.label.." || ~g~"..v.price.."$", {"Attribuer", "Facturer", "Mettre GPS"}, Cfg_Property.main_Menu.pIndex, nil, {}, true, {
                                            onListChange = function(Index, Items)
                                                Cfg_Property.main_Menu.pIndex = Index
                                            end,
                                            onSelected = function()
                                                local player, distance = Cfg_Property.ESXLoaded.Game.GetClosestPlayer()
                                                if Cfg_Property.main_Menu.pIndex == 1 then
                                                    if player ~= -1 and distance <= 3.0 then
                                                        Cfg_Property.ServerSide(Cfg_Property.Prefix..":ownedProperty", GetPlayerServerId(player), v.label, v.propertyID)
                                                        Cfg_Property.Popup("Vous avez attribué la propriété ~b~"..v.label.."~s~ pour ~g~"..v.price.."$")
                                                    else
                                                        Cfg_Property.Popup("~r~Aucun individu à proximité !")
                                                end
                                                elseif Cfg_Property.main_Menu.pIndex == 2 then 
                                                    if player ~= -1 and distance <= 3.0 then
                                                        Cfg_Property.ServerSide('esx_billing:sendBill', GetPlayerServerId(player), "society_realestateagent", "Agence immobilière", tonumber(v.price))
                                                        Cfg_Property.Popup("Vous avez envoyé une facture de : ~g~"..v.price.."$")
                                                    else
                                                        Cfg_Property.Popup("~r~Aucun individu(s) à proximitée !")
                                                    end
                                                else
                                                    SetNewWaypoint(json.decode(v.pEnterPos).x, json.decode(v.pEnterPos).y)
                                                    Cfg_Property.Popup("L'iténaire de la ~b~propriété~s~ a été mis sur votre GPS !")
                                                end
                                            end
                                        })
                                    end
                                end
                                if pCount == 0 then
                                    RageUI.Separator("")
                                    RageUI.Separator(Cfg_Property.main_Menu.Colors[Cfg_Property.main_Menu.MainColors].."Aucune propriété créée")
                                    RageUI.Separator("")
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end)
    RegisterNetEvent(Cfg_Property.Prefix..":refreshPropertyInventory")
    AddEventHandler(Cfg_Property.Prefix..":refreshPropertyInventory", function(propertyInv,pInv,propertyWeight)
        Cfg_Property.main_Menu.propertyInv = propertyInv
        Cfg_Property.main_Menu.pInv = pInv
        Cfg_Property.main_Menu.pWeight = propertyWeight
    end)
    RegisterNetEvent(Cfg_Property.Prefix..":refreshPropertyPlayers")
    AddEventHandler(Cfg_Property.Prefix..":refreshPropertyPlayers", function(propertyPlayers)
        Cfg_Property.main_Menu.playersInProperty = propertyPlayers
    end)
    RegisterNetEvent(Cfg_Property.Prefix..":clochInProperty")
    AddEventHandler(Cfg_Property.Prefix..":clochInProperty", function(pPed, pID, pNumber)
        local pEnter = {}
        local waitEnter = false
        Cfg_Property.Popup("Une personne ~b~souhaite~s~ rentrer chez vous.\n- [~b~Y~s~] pour le faire renter\n- [~r~X~s~] pour refuser")
        Citizen.CreateThread(function()
            waitEnter = true
            Citizen.SetTimeout(7500, function()
                waitEnter = false
            end)
            while waitEnter do
                Citizen.Wait(0)
                if IsControlJustPressed(0, 246) then
                    Cfg_Property.Popup("Vous avez ~b~accepté~s~ l'entrée de la personnee !")
                    Cfg_Property.ServerSide(Cfg_Property.Prefix..":acceptEnter", pPed, pID, pNumber)
                elseif IsControlJustPressed(0, 73) then
                    Cfg_Property.Popup("~r~Vous avez refusé l'entrée de la personne !")
                end
            end
        end)
    end)
    RegisterNetEvent(Cfg_Property.Prefix..":acceptEnter")
    AddEventHandler(Cfg_Property.Prefix..":acceptEnter", function(pID, pNumber)
        Citizen.CreateThread(function()
            Cfg_Property.Popup("Vous êtes entrer dans la ~b~propriété")
            local actualityP = Cfg_Property.main_Menu.propertyList[tonumber(pNumber)]
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
            Cfg_Property.ServerSide(Cfg_Property.Prefix..":exitProperty", pID)
            Cfg_Property.Popup("Vous êtes sortie de la ~b~propriété")
            SetEntityCoords(PlayerPedId(), Cfg_Property.main_Menu.lastPos, false, false, false, false)
            actualityP = nil
        end)
    end)
    RegisterNetEvent(Cfg_Property.Prefix..":kickFromProperty")
    AddEventHandler(Cfg_Property.Prefix..":kickFromProperty", function()
        Cfg_Property.main_Menu.onVisiting = false
        Cfg_Property.Popup("~r~Vous avez été expulser de la propriété")
    end)
    RegisterNetEvent(Cfg_Property.Prefix..":Popup")
    AddEventHandler(Cfg_Property.Prefix..":Popup", function(txt)
        ClearPrints()
        SetNotificationBackgroundColor(140)
        SetNotificationTextEntry("pPopup")
        AddTextEntry("pPopup", txt)
        DrawNotification(false, true)
    end)
    Cfg_Property.Popup = function(txt)
        ClearPrints()
        SetNotificationBackgroundColor(140)
        SetNotificationTextEntry("pClientPopup")
        AddTextEntry("pClientPopup", txt)
        DrawNotification(false, true)
    end
    Cfg_Property.viewMakers = function()
        Citizen.CreateThread(function()
            while Cfg_Property.main_Menu.viewMarkers do
                Citizen.Wait(0)
                for k,v in pairs(Cfg_Property.main_Menu.propertyList[Cfg_Property.main_Menu.intIndex].viewMarkers) do
                    local dst = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.pos, true)
                    DrawMarker(22, v.pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, v.colorsMarker.r, v.colorsMarker.g, v.colorsMarker.b, 255, 55555, false, true, 2, false, false, false, false)
                    if dst < 1.2 then
                        Cfg_Property.ShowFloatingHelpNotification(v.helpMessage, v.pos)
                    end
                end
                for k,v in pairs(Cfg_Property.main_Menu.markersPreview) do
                    local dst = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.pos, true)
                    DrawMarker(22, v.pos.x, v.pos.y,v.pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
                    if dst < 1.5 then
                        Cfg_Property.ShowFloatingHelpNotification(v.message, v.pos)
                    end
                end
            end
        end)
    end
    Cfg_Property.canCreateProperty = function()
        return Cfg_Property.main_Menu.createdProperty.label ~= nil and Cfg_Property.main_Menu.createdProperty.price ~= nil and Cfg_Property.main_Menu.createdProperty.pEnterPos ~= nil and Cfg_Property.main_Menu.createdProperty.gEnterPos ~= nil
    end
    Cfg_Property.convertValue = function(a,b)
        if a == nil then return false else return a..b end
    end
    Cfg_Property.HelpNotif = function(msg)
        AddTextEntry("pHelpNotif", msg)
        BeginTextCommandDisplayHelp("pHelpNotif")
        EndTextCommandDisplayHelp(0, false, true, -1)
    end
    Cfg_Property.ShowFloatingHelpNotification = function(msg, coords)
        AddTextEntry("ShowFloatingHelpNotification", msg)
        SetFloatingHelpTextWorldPosition(1, coords)
        SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
        BeginTextCommandDisplayHelp("ShowFloatingHelpNotification")
        EndTextCommandDisplayHelp(2, false, false, -1)
    end
    Cfg_Property.Keyboard = function()
        local v = nil
        AddTextEntry("CUSTOM_AMOUNT", "Agence immobilière")
        DisplayOnscreenKeyboard(1, "CUSTOM_AMOUNT", '', "", '', '', '', 15)
        while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
            Citizen.Wait(0)
        end
        if UpdateOnscreenKeyboard() ~= 2 then
            v = GetOnscreenKeyboardResult()
            Citizen.Wait(1)
        else
            Citizen.Wait(1)
        end
        return v
    end
    Cfg_Property.changeColorIndex = function()
        Citizen.CreateThread(function()
            Cfg_Property.main_Menu.Colors = {"~p~", "~r~","~o~","~y~","~c~","~g~","~b~"}
            Cfg_Property.main_Menu.ColorsTwo = {"~r~", "~p~","~y~","~o~","~g~","~b~","~c~"}
            Cfg_Property.main_Menu.MainColors = 1
            if Cfg_Property.main_Menu.menuIsOpen then
                while Cfg_Property.main_Menu.menuIsOpen do 
                    Citizen.Wait(500)
                    Cfg_Property.main_Menu.MainColors = Cfg_Property.main_Menu.MainColors + 1
                    if Cfg_Property.main_Menu.MainColors > #Cfg_Property.main_Menu.Colors then Cfg_Property.main_Menu.MainColors = 1 end
                end
            elseif Cfg_Property.main_Menu.viewMenuIsOpen then
                while Cfg_Property.main_Menu.viewMenuIsOpen do 
                    Citizen.Wait(500)
                    Cfg_Property.main_Menu.MainColors = Cfg_Property.main_Menu.MainColors + 1
                    if Cfg_Property.main_Menu.MainColors > #Cfg_Property.main_Menu.Colors then Cfg_Property.main_Menu.MainColors = 1 end
                end
            elseif Cfg_Property.main_Menu.ownedMenuIsOpen then
                while Cfg_Property.main_Menu.ownedMenuIsOpen do 
                    Citizen.Wait(500)
                    Cfg_Property.main_Menu.MainColors = Cfg_Property.main_Menu.MainColors + 1
                    if Cfg_Property.main_Menu.MainColors > #Cfg_Property.main_Menu.Colors then Cfg_Property.main_Menu.MainColors = 1 end
                end
            elseif Cfg_Property.main_Menu.manageMenuIsOpen then
                while Cfg_Property.main_Menu.manageMenuIsOpen do 
                    Citizen.Wait(500)
                    Cfg_Property.main_Menu.MainColors = Cfg_Property.main_Menu.MainColors + 1
                    if Cfg_Property.main_Menu.MainColors > #Cfg_Property.main_Menu.Colors then Cfg_Property.main_Menu.MainColors = 1 end
                end
            elseif Cfg_Property.main_Menu.dressingMenuIsOpen then
                while Cfg_Property.main_Menu.dressingMenuIsOpen do 
                    Citizen.Wait(500)
                    Cfg_Property.main_Menu.MainColors = Cfg_Property.main_Menu.MainColors + 1
                    if Cfg_Property.main_Menu.MainColors > #Cfg_Property.main_Menu.Colors then Cfg_Property.main_Menu.MainColors = 1 end
                end
            end
        end)
    end
    RegisterCommand("openProperty", function()
        if Cfg_Property.ESXLoaded.PlayerData.job.name == "realestateagent" then
            Cfg_Property.ServerSide(Cfg_Property.Prefix..":openMainMenu")
        end
    end)
    RegisterKeyMapping("openProperty", "Menu intéraction de l'agence immobilière", "keyboard", "F6")
end)