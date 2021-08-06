Cfg_Property.ESXLoaded = nil
Cfg_Property.InSide(Cfg_Property.ESXEvent, function(esxEvent) Cfg_Property.ESXLoaded = esxEvent end)

RegisterServerEvent(Cfg_Property.Prefix..":openMainMenu")
AddEventHandler(Cfg_Property.Prefix..":openMainMenu",function()
    local source = source
    Cfg_Property.ClientSide(Cfg_Property.Prefix..":openMainMenu", source)
end)

RegisterServerEvent(Cfg_Property.Prefix..":requestProperty")
AddEventHandler(Cfg_Property.Prefix..":requestProperty",function()
    local source = source
    MySQL.Async.fetchAll("SELECT * FROM property_created", {},
    function(pExisted)
        if pExisted[1] then
            Cfg_Property.ClientSide(Cfg_Property.Prefix..":requestProperty", source, pExisted, GetPlayerIdentifier(source))
        else
            Cfg_Property.ClientSide(Cfg_Property.Prefix..":requestProperty", source, {}, GetPlayerIdentifier(source))
        end
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":createProperty")
AddEventHandler(Cfg_Property.Prefix..":createProperty",function(property)
    local source = source
    local houseExisted = false
    MySQL.Async.fetchAll("SELECT * FROM property_created", {},
    function(pExisted)
        if pExisted[1] then
            if pExisted[1].label == property.label then
                houseExisted = true
            else
                houseExisted = false
            end
        else
            houseExisted = false
        end
        if houseExisted then 
            Cfg_Property.ClientSide(Cfg_Property.Prefix..":Popup", source,"~r~Une propriété a déjà été créer sous ce nom !")
        else 
            MySQL.Async.execute("INSERT INTO property_created (label,price,pNumber,pEnterPos,gEnterPos,gPlaces,stockCapacity) VALUES (@label,@price,@pNumber,@pEnterPos,@gEnterPos,@gPlaces,@stockCapacity)", {
                ["@label"] = property.label,
                ["@price"] = property.price,
                ["@pNumber"] = property.pNumber,
                ["@pEnterPos"] = json.encode(property.pEnterPos),
                ["@gEnterPos"] = json.encode(property.gEnterPos),
                ["@gPlaces"] = property.gPlaces,
                ["@stockCapacity"] = property.stockCapacity,
            }, function()
                MySQL.Async.fetchAll("SELECT * FROM property_created", {},
                function(actualityProperty)
                    Cfg_Property.ClientSide(Cfg_Property.Prefix..":requestProperty", -1, actualityProperty, nil)
                end)
            end)
        end
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":ownedProperty")
AddEventHandler(Cfg_Property.Prefix..":ownedProperty",function(player, label, pID)
    MySQL.Async.fetchAll("UPDATE property_created SET owner=@owner WHERE propertyID=@propertyID", {
        ["@propertyID"] = pID,
        ["@owner"] = GetPlayerIdentifier(player), 
    }, function()
        TriggerClientEvent(Cfg_Property.Prefix..":Popup", player, "Vous avez reçu les clés de la propriété : ~b~"..label)
        Citizen.Wait(500)
        MySQL.Async.fetchAll("SELECT * FROM property_created", {},
        function(actualityProperty)
            Cfg_Property.ClientSide(Cfg_Property.Prefix..":requestProperty", -1, actualityProperty, nil)
        end)
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":refreshPropertyInventory")
AddEventHandler(Cfg_Property.Prefix..":refreshPropertyInventory",function(pID)
    local source = source
    local pPed = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID=@propertyID", {
        ["@propertyID"] = pID,
    },
    function(actualityProperty)
        local pPed = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
        local pInfos = json.decode(actualityProperty[1].pInventory)
        if pInfos.Inv == nil then pInfos.Inv = {} end
        if pInfos.Loadout == nil then pInfos.Loadout = {} end
        if pInfos.Money == nil then pInfos.Money = {} end
        Cfg_Property.ClientSide(Cfg_Property.Prefix..":refreshPropertyInventory", source, pInfos, {pInventory = pPed.inventory, pMoney = pPed.getAccount("black_money").money, pLoadout = pPed.loadout}, Cfg_Property.GetCoffreWeight(pInfos.Inv, pInfos.Loadout, pInfos.Money))
    end)
end)

Cfg_Property.GetCoffreWeight = function(inv, loadout, money)
    local pWeight = 0
    for k,v in pairs(inv) do
        local itemWeight = Cfg_Property.DefaultWeight
        if Cfg_Property.itemsWeight[k] ~= nil then
            itemWeight = Cfg_Property.itemsWeight[k]
        end
        pWeight = pWeight + (itemWeight * v.count)
    end
    for k,v in pairs(loadout) do
        local itemWeight = Cfg_Property.DefaultWeight
        if Cfg_Property.itemsWeight[k] ~= nil then
            itemWeight = Cfg_Property.itemsWeight[k]
        end
        pWeight = pWeight + (itemWeight * v.count)
    end
    for k,v in pairs(money) do
        local itemWeight = Cfg_Property.DefaultWeight
        if Cfg_Property.itemsWeight[k] ~= nil then
            itemWeight = Cfg_Property.itemsWeight[k]
        end
        pWeight = pWeight + (itemWeight * v.count)
    end
    return pWeight
end

RegisterServerEvent(Cfg_Property.Prefix..":depositInProperty")
AddEventHandler(Cfg_Property.Prefix..":depositInProperty",function(pID, itemName, itemLabel, count, itemType)
    local source = source
    local pPed = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID=@propertyID", {
        ["@propertyID"] = pID,
    }, function(p)
        local propertyInventory = json.decode(p[1].pInventory)
        if itemType == "item" then
            if propertyInventory.Inv == nil then propertyInventory.Inv = {} end            
            if propertyInventory.Inv[itemName] == nil then 
                propertyInventory.Inv[itemName] = {count = count, label = itemLabel}
            else 
                propertyInventory.Inv[itemName] = {count = propertyInventory.Inv[itemName].count + count, label = itemLabel} 
            end
            pPed.removeInventoryItem(itemName, count)
        elseif itemType == "weapon" then
            if propertyInventory.Loadout == nil then propertyInventory.Loadout = {} end            
            if propertyInventory.Loadout[itemName] == nil then 
                propertyInventory.Loadout[itemName] = {count = count, label = itemLabel}
            else 
                propertyInventory.Loadout[itemName] = {count = propertyInventory.Loadout[itemName].count + count, label = itemLabel} 
            end
            pPed.removeWeapon(itemName)
        else
            if propertyInventory.Money == nil then propertyInventory.Money = {} end            
            if propertyInventory.Money[itemName] == nil then 
                propertyInventory.Money[itemName] = {count = 1, money = count, label = itemLabel}
            else 
                propertyInventory.Money[itemName] = {count = 1, money = propertyInventory.Money[itemName].money + count, label = itemLabel} 
            end
            pPed.removeAccountMoney(itemName, count)
        end
        MySQL.Async.fetchAll("UPDATE property_created SET pInventory=@pInventory WHERE propertyID=@propertyID", {
            ["@propertyID"] = pID,
            ["@pInventory"] = json.encode(propertyInventory), 
        }, function()
            MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID=@propertyID", {
                ["@propertyID"] = pID,
            },
            function(actualityProperty)
                local pPed = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
                local pInfos = json.decode(actualityProperty[1].pInventory)
                if pInfos.Inv == nil then pInfos.Inv = {} end
                if pInfos.Loadout == nil then pInfos.Loadout = {} end
                if pInfos.Money == nil then pInfos.Money = {} end
                Cfg_Property.ClientSide(Cfg_Property.Prefix..":refreshPropertyInventory", source, pInfos, {pInventory = pPed.inventory, pMoney = pPed.getAccount("black_money").money, pLoadout = pPed.loadout}, Cfg_Property.GetCoffreWeight(pInfos.Inv, pInfos.Loadout, pInfos.Money))
            end)
        end)
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":takeInProperty")
AddEventHandler(Cfg_Property.Prefix..":takeInProperty",function(pID, itemName, count, itemType)
    local source = source
    local pPed = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
    MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID=@propertyID", {
        ["@propertyID"] = pID,
    }, function(p)
        local propertyInventory = json.decode(p[1].pInventory)
        if itemType == "item" then
            if propertyInventory.Inv == nil then propertyInventory.Inv = {} end            
            if propertyInventory.Inv[itemName] == nil then 
                return
            elseif propertyInventory.Inv[itemName].count - count <= 0 then
                propertyInventory.Inv[itemName] = nil
            else 
                propertyInventory.Inv[itemName].count = propertyInventory.Inv[itemName].count - count
            end
            pPed.addInventoryItem(itemName, count)
        elseif itemType == "weapon" then
            if propertyInventory.Loadout == nil then propertyInventory.Loadout = {} end            
            if propertyInventory.Loadout[itemName] == nil then 
                return
            elseif propertyInventory.Loadout[itemName].count - count <= 0 then
                propertyInventory.Loadout[itemName] = nil
            else 
                propertyInventory.Loadout[itemName].count = propertyInventory.Loadout[itemName].count - count
            end
            pPed.addWeapon(itemName)
        else
            if propertyInventory.Money == nil then propertyInventory.Money = {} end            
            if propertyInventory.Money[itemName] == nil then 
                return
            elseif propertyInventory.Money[itemName].money <= 0 then
                propertyInventory.Money[itemName] = nil
            else 
                propertyInventory.Money[itemName].money = propertyInventory.Money[itemName].money - count
            end
            pPed.addAccountMoney(itemName, count)
        end
        MySQL.Async.fetchAll("UPDATE property_created SET pInventory=@pInventory WHERE propertyID=@propertyID", {
            ["@propertyID"] = pID,
            ["@pInventory"] = json.encode(propertyInventory), 
        }, function()
            MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID=@propertyID", {
                ["@propertyID"] = pID,
            },
            function(actualityProperty)
                local pPed = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
                local pInfos = json.decode(actualityProperty[1].pInventory)
                if pInfos.Inv == nil then pInfos.Inv = {} end
                if pInfos.Loadout == nil then pInfos.Loadout = {} end
                if pInfos.Money == nil then pInfos.Money = {} end
                Cfg_Property.ClientSide(Cfg_Property.Prefix..":refreshPropertyInventory", source, pInfos, {pInventory = pPed.inventory, pMoney = pPed.getAccount("black_money").money, pLoadout = pPed.loadout}, Cfg_Property.GetCoffreWeight(pInfos.Inv, pInfos.Loadout, pInfos.Money))
            end)
        end)
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":enterInProperty")
AddEventHandler(Cfg_Property.Prefix..":enterInProperty",function(pID)
    local source = source
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier=@identifier", {
        ["@identifier"] = GetPlayerIdentifier(source),
    },
    function(pUsers)
        if pUsers[1] then
            SetPlayerRoutingBucket(source, (100+pID))
            if Cfg_Property.pInProperty[pID] == nil then
                Cfg_Property.pInProperty[pID] = {}
            end
            table.insert(Cfg_Property.pInProperty[pID], {
                pSource = source,
                pName = pUsers[1].firstname.." - "..pUsers[1].lastname,
                pIdentifier = GetPlayerIdentifier(source)
            })
            Cfg_Property.ClientSide(Cfg_Property.Prefix..":refreshPropertyPlayers", -1, Cfg_Property.pInProperty)
        else
            SetPlayerRoutingBucket(source, (100+pID))
            if Cfg_Property.pInProperty[pID] == nil then
                Cfg_Property.pInProperty[pID] = {}
            end
            table.insert(Cfg_Property.pInProperty[pID], {
                pSource = source,
                pName = "Nom inconnu".." - ".."Prénom inconnu",
                pIdentifier = GetPlayerIdentifier(source)
            })
            Cfg_Property.ClientSide(Cfg_Property.Prefix..":refreshPropertyPlayers", -1, Cfg_Property.pInProperty)
            return print("Erreur lors du chargement de la propriété")
        end
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":exitProperty")
AddEventHandler(Cfg_Property.Prefix..":exitProperty",function(pID, pK)
    local source = source
    for k,v in pairs(Cfg_Property.pInProperty[pID]) do
        if v.pSource == source then 
            table.remove(Cfg_Property.pInProperty[pID], pK)
        end
    end
    Cfg_Property.ClientSide(Cfg_Property.Prefix..":refreshPropertyPlayers", -1, Cfg_Property.pInProperty)
    SetPlayerRoutingBucket(source, 0)
end)

RegisterServerEvent(Cfg_Property.Prefix..":clochInProperty")
AddEventHandler(Cfg_Property.Prefix..":clochInProperty", function(pID, pNumber)
    local source = source
    MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID=@propertyID", {
        ["@propertyID"] = pID,
    },
    function(property)
        local pPed = Cfg_Property.ESXLoaded.GetPlayerFromIdentifier(property[1].owner)
        if pPed == nil then
            return
        else
            Cfg_Property.ClientSide(Cfg_Property.Prefix..":clochInProperty", pPed.source, source, pID, pNumber)
        end
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":acceptEnter")
AddEventHandler(Cfg_Property.Prefix..":acceptEnter", function(player, pID, pNumber)
    local pPed = Cfg_Property.ESXLoaded.GetPlayerFromId(player)
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier=@identifier", {
        ["@identifier"] = GetPlayerIdentifier(pPed.source),
    },
    function(pUsers)
        if pUsers[1] then
            SetPlayerRoutingBucket(pPed.source, (100+pID))
            if Cfg_Property.pInProperty[pID] == nil then
                Cfg_Property.pInProperty[pID] = {}
            end
            table.insert(Cfg_Property.pInProperty[pID], {
                pSource = pPed.source,
                pName = pUsers[1].firstname.." - "..pUsers[1].lastname,
                pIdentifier = GetPlayerIdentifier(pPed.source)
            })
            Cfg_Property.ClientSide(Cfg_Property.Prefix..":refreshPropertyPlayers", -1, Cfg_Property.pInProperty)
        else
            return print("Erreur lors du chargement de la propriété")
        end
        Cfg_Property.ClientSide(Cfg_Property.Prefix..":acceptEnter", pPed.source, pID, pNumber)
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":SetPlayerInBucket")
AddEventHandler(Cfg_Property.Prefix..":SetPlayerInBucket", function(number)
    local source = source
    SetPlayerRoutingBucket(source, number)
end)

RegisterServerEvent(Cfg_Property.Prefix..":addKeyProperty")
AddEventHandler(Cfg_Property.Prefix..":addKeyProperty", function(pID, pIdentifier)
    MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID=@propertyID", {
        ["@propertyID"] = pID,
    }, function(p)
        local propertyKeys = json.decode(p[1].pKeys)
        propertyKeys[pIdentifier] = {}
        MySQL.Async.fetchAll("UPDATE property_created SET pKeys=@pKeys WHERE propertyID=@propertyID", {
            ["@propertyID"] = pID,
            ["@pKeys"] = json.encode(propertyKeys), 
        }, function()
            Citizen.Wait(500)
            MySQL.Async.fetchAll("SELECT * FROM property_created", {},
            function(actualityProperty)
                Cfg_Property.ClientSide(Cfg_Property.Prefix..":requestProperty", -1, actualityProperty, nil)
            end)
        end)
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":removeKeyProperty")
AddEventHandler(Cfg_Property.Prefix..":removeKeyProperty", function(pID, pIdentifier)
    MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID=@propertyID", {
        ["@propertyID"] = pID,
    }, function(p)
        local propertyKeys = json.decode(p[1].pKeys)
        propertyKeys[pIdentifier] = nil
        MySQL.Async.fetchAll("UPDATE property_created SET pKeys=@pKeys WHERE propertyID=@propertyID", {
            ["@propertyID"] = pID,
            ["@pKeys"] = json.encode(propertyKeys), 
        }, function()
            Citizen.Wait(500)
            MySQL.Async.fetchAll("SELECT * FROM property_created", {},
            function(actualityProperty)
                Cfg_Property.ClientSide(Cfg_Property.Prefix..":requestProperty", -1, actualityProperty, nil)
            end)
        end)
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":kickFromProperty")
AddEventHandler(Cfg_Property.Prefix..":kickFromProperty", function(pID, pIdentifier)
    local pPed = Cfg_Property.ESXLoaded.GetPlayerFromIdentifier(pIdentifier)
    Cfg_Property.ClientSide(Cfg_Property.Prefix..":kickFromProperty", pPed.source)
end)

RegisterNetEvent(Cfg_Property.Prefix..":addVehiculeInProperty")
AddEventHandler(Cfg_Property.Prefix..":addVehiculeInProperty", function(plate, props, propertyID)
    local source = source
    MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID = @propertyID", {
        ["@propertyID"] = propertyID,
    }, function(pResult)
        if pResult[1] then
            local gVehicules = {}
            gVehicules[propertyID] = json.decode((pResult[1].pVehicules))
            table.insert(gVehicules[propertyID], {
                props = props,
                plate = plate,
            })
            MySQL.Async.execute("UPDATE property_created SET pVehicules = @pVehicules WHERE propertyID = @propertyID", {
                ["@propertyID"] = propertyID,
                ["@pVehicules"] = json.encode(gVehicules[propertyID]),
            }, function()
                Cfg_Property.ClientSide(Cfg_Property.Prefix..":Popup", source, "Votre véhicule a été ~b~rangé~s~ dans votre garage !")
                MySQL.Async.fetchAll("SELECT * FROM property_created", {},
                function(actualityProperty)
                    Cfg_Property.ClientSide(Cfg_Property.Prefix..":requestProperty", -1, actualityProperty, nil)
                end)
            end)
            gVehicules[propertyID] = {}
        end
    end)
end)

RegisterNetEvent(Cfg_Property.Prefix..":outVehiculeFromProperty")
AddEventHandler(Cfg_Property.Prefix..":outVehiculeFromProperty", function(propertyID, key)
    local source = source
    MySQL.Async.fetchAll("SELECT * FROM property_created WHERE propertyID = @propertyID", {
        ["@propertyID"] = propertyID,
    }, function(pResult)
        if pResult[1] then
            local gVehicules = {}
            gVehicules[propertyID] = json.decode(pResult[1].pVehicules)
            table.remove(gVehicules[propertyID], key)
            MySQL.Async.execute("UPDATE property_created SET pVehicules = @pVehicules WHERE propertyID = @propertyID", {
                ["@propertyID"] = propertyID,
                ["@pVehicules"] = json.encode(gVehicules[propertyID])
            }, function()
                Cfg_Property.ClientSide(Cfg_Property.Prefix..":Popup", source, "Votre véhicule a été ~b~sortie~s~ dans votre garage !")
                MySQL.Async.fetchAll("SELECT * FROM property_created", {},
                function(actualityProperty)
                    Cfg_Property.ClientSide(Cfg_Property.Prefix..":requestProperty", -1, actualityProperty, nil)
                end)
            end)
        end
    end)
end)

RegisterServerEvent(Cfg_Property.Prefix..":DeleteOutfit")
AddEventHandler(Cfg_Property.Prefix..":DeleteOutfit", function(label)
	local xPlayer = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
	TriggerEvent("esx_datastore:getDataStore", "property", xPlayer.identifier, function(store)
		local dressing = store.get("dressing")
		if dressing == nil then
			dressing = {}
		end
		table.remove(dressing, label)
		store.set("dressing", dressing)
	end)
end)

Cfg_Property.ESXLoaded.RegisterServerCallback(Cfg_Property.Prefix..":GetPlyDressing", function(source, cb)
  local xPlayer = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
  TriggerEvent("esx_datastore:getDataStore", "property", xPlayer.identifier, function(store)
        local count = store.count("dressing")
        local labels = {}
        for i=1, count, 1 do
            local entry = store.get("dressing", i)
            table.insert(labels, entry.label)
        end
        cb(labels, 1)
    end)
end)

Cfg_Property.ESXLoaded.RegisterServerCallback(Cfg_Property.Prefix..":GetPlyOutfit", function(source, cb, num)
  local xPlayer  = Cfg_Property.ESXLoaded.GetPlayerFromId(source)
    TriggerEvent("esx_datastore:getDataStore", "property", xPlayer.identifier, function(store)
        local outfit = store.get("dressing", num)
        cb(outfit.skin)
    end)
end)