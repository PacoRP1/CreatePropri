Cfg_Property.openPropertyDressing = function(pK,pV)
    RMenu.Add("nProperty_Dressing", "main_menu", RageUI.CreateMenu("Propriété","INTÉRACTIONS"))
    RMenu:Get("nProperty_Dressing", "main_menu").Closed = function()
        Cfg_Property.main_Menu.dressingMenuIsOpen = false 
    end
    if Cfg_Property.main_Menu.dressingMenuIsOpen then
        RageUI.CloseAll()
        Cfg_Property.main_Menu.dressingMenuIsOpen = false
    else
        Cfg_Property.main_Menu.dressingMenuIsOpen = true
        RageUI.Visible(RMenu:Get("nProperty_Dressing", "main_menu"), true)
        Citizen.CreateThread(function()
            Cfg_Property.changeColorIndex()
            while Cfg_Property.ESXLoaded == nil do
                Cfg_Property.InSide(Cfg_Property.ESXEvent, function(esxEvent) Cfg_Property.ESXLoaded = esxEvent end)
                Citizen.Wait(0)
            end
            Cfg_Property.main_Menu.pDressing = {}
            Cfg_Property.ESXLoaded.TriggerServerCallback(Cfg_Property.Prefix..":GetPlyDressing", function(d)
                Cfg_Property.main_Menu.pDressing = d
            end)
            Cfg_Property.main_Menu.totalCount = 0
            while Cfg_Property.main_Menu.dressingMenuIsOpen do
                Citizen.Wait(0)
                RageUI.IsVisible(RMenu:Get("nProperty_Dressing", "main_menu"), function()
                    if Cfg_Property.main_Menu.Colors ~= nil then
                        if Cfg_Property.main_Menu.totalCount == 0 then
                            RageUI.Separator("")
                            RageUI.Separator(Cfg_Property.main_Menu.Colors[Cfg_Property.main_Menu.MainColors].."Vous n'avez pas de tenue !")
                            RageUI.Separator("")
                        else
                            RageUI.Separator("↓ "..Cfg_Property.main_Menu.Colors[Cfg_Property.main_Menu.MainColors].."Liste des tenue(s)~s~ ↓")
                        end
                        for k,v in pairs(Cfg_Property.main_Menu.pDressing) do
                            Cfg_Property.main_Menu.totalCount = Cfg_Property.main_Menu.totalCount+1
                            RageUI.List("Tenue : "..v, {"Mettre", "Effacer"}, Cfg_Property.main_Menu.pDressingIndex, nil, {}, true, {
                                onListChange = function(Index,Items)
                                    Cfg_Property.main_Menu.pDressingIndex = Index
                                end,
                                onSelected = function()
                                    if Cfg_Property.main_Menu.pDressingIndex == 1 then
                                        TriggerEvent('skinchanger:getSkin', function(skin)
                                            Cfg_Property.ESXLoaded.TriggerServerCallback(Cfg_Property.Prefix..":GetPlyOutfit", function(c)
                                                TriggerEvent('skinchanger:loadClothes', skin, c)
                                                TriggerEvent('esx_skin:setLastSkin', skin)
                                                TriggerEvent('skinchanger:getSkin', function(skin)
                                                    Cfg_Property.ServerSide('esx_skin:save', skin)
                                                end)
                                            end, k)
                                        end)
                                        Cfg_Property.Popup("Vous avez mis votre tenue : ~b~"..v)
                                    else
                                        Cfg_Property.ServerSide(Cfg_Property.Prefix..":DeleteOutfit", k)
                                        Cfg_Property.main_Menu.pDressing = {}
                                        Cfg_Property.ESXLoaded.TriggerServerCallback(Cfg_Property.Prefix..":GetPlyDressing", function(d)
                                            Cfg_Property.main_Menu.pDressing = d
                                        end)
                                        Cfg_Property.main_Menu.totalCount = 0
                                        Cfg_Property.Popup("Vous avez effacer la tenue : ~b~"..v.."~s~ de votre dressing !")
                                    end
                                end,
                            })
                        end
                    end
                end)
            end
        end)
    end
end