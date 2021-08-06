Cfg_Property = {
    Prefix = "nProperty",
    Credit = "nProperty is started, ",
    ESXEvent = "esx:getSharedObject",
    ESXLoaded = nil,
    ServerSide = TriggerServerEvent,
    ClientSide = TriggerClientEvent,
    InSide = TriggerEvent,
    prt = print,
    ActualityProperty = {},
    DefaultWeight = 1000, -- 1KG
    pInProperty = {},
    main_Menu = {
        totalCount = 100,
        menuIsOpen = false,
        viewMenuIsOpen = false,
        manageIndex = 1,
        trIndex = 1,
        trItemsIndex = 1,
        intIndex = 1,
        gIndex = 1,
        stockIndex = 1,
        pIndex = 1,
        pDressingIndex =1,
        createdProperty = {
            pNumber = 1,
            gPlaces = 2,
            stockCapacity = 50,
        },
        markersPreview = {},
        pDressing = {},
        playersInProperty = {},
        capacityList = {50,100,150,200,250,300,350,400,450,500},
        garagePlacesList = {2,4,6,10},
        propertyList = {
            {
                label = "Petite maison",
                interiorEntry = {pos = vector3(151.30, -1007.70, -98.99), heading = 357.0},
                interiorExit = {pos = vector3(151.30, -1007.70, -98.99), colorsMarker = {r = 0, g = 255, b = 0}},
                pStock = {pos = vector3(151.8233, -1001.056, -98.99998), colorsMarker = {r = 255, g = 0, b = 0}},
                pDressing = {pos = vector3(151.3306, -1003.132, -98.99995), colorsMarker = {r = 255, g = 0, b = 0}},
                viewMarkers = {
                    {pos =  vector3(151.30, -1007.70, -98.99), colorsMarker = {r = 0, g = 255, b = 0}, helpMessage = "~b~TYPE D'INTÉRACTION~s~\n- Point de sortie de la propriété"},
                }
            },
            {
                label = "Petite maison 2",
                interiorEntry = {pos = vector3(266.05, -1007.20, -101.00), heading = 16.52},
                interiorExit = {pos = vector3(266.05, -1007.20, -101.00), colorsMarker = {r = 0, g = 255, b = 0}},
                pStock = {pos = vector3(259.6676, -1003.984, -99.00859), colorsMarker = {r = 255, g = 0, b = 0}},
                pDressing = {pos = vector3(261.3669, -1002.563, -99.00859), colorsMarker = {r = 255, g = 0, b = 0}},
                viewMarkers = {
                    {pos =  vector3(266.05, -1007.20, -101.00), colorsMarker = {r = 0, g = 255, b = 0}, helpMessage = "~b~TYPE D'INTÉRACTION~s~\n- Point de sortie de la propriété"},
                }
            },
            {
                label = "Petite maison 3",
                interiorEntry = {pos = vector3(346.52, -1012.61, -99.19), heading = 0.7},
                interiorExit = {pos = vector3(346.52, -1012.61, -99.19), colorsMarker = {r = 0, g = 255, b = 0}},
                pStock = {pos = vector3(351.2698, -999.2122, -99.19618), colorsMarker = {r = 255, g = 0, b = 0}},
                pDressing = {pos = vector3(350.8228, -993.5939, -99.19618), colorsMarker = {r = 255, g = 0, b = 0}},
                viewMarkers = {
                    {pos =  vector3(346.52, -1012.61, -99.19), colorsMarker = {r = 0, g = 255, b = 0}, helpMessage = "~b~TYPE D'INTÉRACTION~s~\n- Point de sortie de la propriété"},
                }
            },
            {
                label = "Maison luxe",
                interiorEntry = {pos = vector3(-18.53, -591.68, 90.11), heading = 347.98},
                interiorExit = {pos = vector3(-18.53, -591.68, 90.11), colorsMarker = {r = 0, g = 255, b = 0}},
                pStock = {pos = vector3(-26.63897, -587.4516, 90.1235), colorsMarker = {r = 255, g = 0, b = 0}},
                pDressing = {pos = vector3(-28.4853, -591.0581, 90.1177), colorsMarker = {r = 255, g = 0, b = 0}},
                viewMarkers = {
                    {pos =  vector3(-18.53, -591.68, 90.11), colorsMarker = {r = 0, g = 255, b = 0}, helpMessage = "~b~TYPE D'INTÉRACTION~s~\n- Point de sortie de la propriété"},
                }
            },
            {
                label = "Maison luxe 2",
                interiorEntry = {pos = vector3(-859.85, 691.153, 152.86), heading = 207.98},
                interiorExit = {pos = vector3(-859.85, 691.153, 152.86), colorsMarker = {r = 0, g = 255, b = 0}},
                pStock = {pos = vector3(-858.2318, 697.5743, 145.253), colorsMarker = {r = 255, g = 0, b = 0}},
                pDressing = {pos = vector3(-857.3516, 701.2546, 145.253), colorsMarker = {r = 255, g = 0, b = 0}},
                viewMarkers = {
                    {pos =  vector3(-859.85, 691.153, 152.86), colorsMarker = {r = 0, g = 255, b = 0}, helpMessage = "~b~TYPE D'INTÉRACTION~s~\n- Point de sortie de la propriété"},
                }
            },
        }
    },
    garageInteriorsInfos = {
        [2] = {
            tpPos = vector3(178.69, -1006.31, -99.0), 
            tpExit = vector3(178.69, -1006.31, -99.0), 
            vehiculeSpawner = {
                {pos = vector3(175.22, -1003.46, -99.0), heading = 183.32},
                {pos = vector3(171.07, -1003.78, -99.), heading = 180.28}
            }, 
        },
        [4] = {
            tpPos = vector3(206.88, -1018.4, -99.0), 
            tpExit = vector3(206.88, -1018.4, -99.0), 
            vehiculeSpawner= {
                {pos = vector3(194.50, -1016.14, -99.0), heading = 180.13},
                {pos = vector3(194.57, -1022.32, -99.0), heading = 180.13},
                {pos = vector3(202.21, -1020.14, -99.0), heading = 90.13},
                {pos = vector3(202.21, -1023.32, -99.0), heading = 90.13}
            }
        },
        [6] = {
            tpPos = vector3(206.79, -999.08, -99.0), 
            tpExit = vector3(206.79, -999.08, -99.0), 
            vehiculeSpawner = {
                {pos = vector3(203.82, -1004.63, -99.0), heading = 88.05},
                {pos = vector3(194.16, -1004.63, -99.0), heading = 266.42},
                {pos = vector3(193.83, -1000.63, -99.0), heading = 266.42},
                {pos = vector3(202.62, -1000.63, -99.0), heading = 88.05},
                {pos = vector3(193.83, -997.01, -99.0), heading = 266.42},
                {pos = vector3(202.62, -997.01, -99.0), heading = 88.05},
            },
        },
        [10] = {
            tpPos = vector3(240.71, -1004.96, -99.0), 
            tpExit = vector3(240.71, -1004.96, -99.0), 
            vehiculeSpawner = {
                {pos = vector3(233.47, -982.57, -99.0), heading = 90.1},
                {pos = vector3(233.47, -987.57, -99.0), heading = 90.1},
                {pos = vector3(233.47, -992.57, -99.0), heading = 90.1},
                {pos = vector3(233.47, -997.57, -99.0), heading = 90.1},
                {pos = vector3(233.47, -1002.57, -99.0), heading = 90.1},
                {pos = vector3(223.55, -982.57, -99.0), heading = 266.36},
                {pos = vector3(223.55, -987.57, -99.0), heading = 266.36},
                {pos = vector3(223.55, -992.57, -99.0), heading = 266.36},
                {pos = vector3(223.55, -997.57, -99.0), heading = 266.36},
                {pos = vector3(223.55, -1002.57, -99.0), heading = 266.36},
            },
        },
    },
    itemsWeight = {
        --[[
            Liste des items qui auront un poids "personnalisé", à vous d'en ajouté si cela est nécessaire !
        ]]
        -- Argent sale
        ["black_money"] = 750,
        -- Arme(s) 
        ["WEAPON_PISTOL"] = 2500,
        -- Item(s)
        ["bread"] = 1250,
    },
}