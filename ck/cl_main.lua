ESX = nil
local spawnattu = false
local alotettu = false
local autossa = false
local myymassa = false
local myyty = false
local kilpi = ""
local perse = {}
local blip
local car
local hakumestat = {
    [1] = {coords=vector3(-1271.6595458984, -1428.0672607422, 4.353771686554), auto="adder", aika = 300},
    [2] = {coords=vector3(-476.43618774414, 269.97619628906, 83.199203491211), auto="entity2", aika = 300}
}
    

local myyntimestat = {
    [1] = {coords=vector3(-1271.6595458984,-1428.0672607422,4.353771686554), hinta = math.random(45000, 85000)},
    [2] = {coords=vector3(-476.43618774414,269.97619628906,83.199203491211), hinta = math.random(45000, 85000)},
    [3] = {coords=vector3(324.39654541016,96.952049255371,99.705718994141), hinta = math.random(45000, 85000)},
    [4] = {coords=vector3(1915.4074707031,582.55914306641,176.36744689941), hinta = math.random(45000, 85000)},
    [5] = {coords=vector3(2954.1950683594,2735.6857910156,44.326873779297), hinta = math.random(45000, 85000)},
    [6] = {coords=vector3(2594.7673339844,479.42660522461,108.48071289063), hinta = math.random(45000, 85000)},
    [7] = {coords=vector3(2670.3581542969,1600.7271728516,24.500690460205), hinta = math.random(45000, 85000)},
    [8] = {coords=vector3(173.69543457031,2778.6369628906,46.077301025391), hinta = math.random(45000, 85000)},
    [9] = {coords=vector3(639.78247070313,2778.388671875,41.973861694336), hinta = math.random(45000, 85000)},
    [10] = {coords=vector3(558.65557861328,2657.7346191406,42.168830871582), hinta = math.random(45000, 85000)},
    [11] = {coords=vector3(1894.267578125,3715.015625,32.761547088623), hinta = math.random(45000, 85000)},
    [12] = {coords=vector3(1219.2553710938,-3204.8894042969,5.6542053222656), hinta = math.random(45000, 85000)},
}


CreateThread(function()
    while ESX == nil do
        Wait(10)
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
    end
    TriggerServerEvent('karpo_tuontiauto:serverista')
    Wait(7000)
    while true do
        local wait = 1500
        for i=1, #perse do
           local coords = GetEntityCoords(PlayerPedId())
           local lol = perse[i].pos
           if not perse[i].luotu then
                if Vdist(coords.x, coords.y, coords.z, lol.x, lol.y, lol.z) < 150.0 then
                    RequestModel(GetHashKey(perse[i].pedmodel))
                    while not HasModelLoaded(GetHashKey(perse[i].pedmodel)) do
                        Citizen.Wait(1)
                    end
                    RequestAnimDict(perse[i].npcanimaatio)
                    while not HasAnimDictLoaded(perse[i].npcanimaatio) do
                        Citizen.Wait(1)
                    end
                    Wait(100)	
                    local pedi = CreatePed(4, GetHashKey(perse[i].pedmodel), lol.x, lol.y, lol.z, perse[i].heading, false, true)
                    SetPedCanRagdollFromPlayerImpact(pedi, false)
                    SetPedCanEvasiveDive(pedi, false)
                    SetPedCanBeTargetted(pedi, false)
                    SetEntityInvincible(pedi, true)
                    SetBlockingOfNonTemporaryEvents(pedi, true)
                    TaskPlayAnim(pedi,perse[i].npcanimaatio,perse[i].npcanimaatio2,1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
                    perse[i].luotu = true
                end
            end
            if Vdist(coords.x, coords.y, coords.z, lol.x, lol.y, lol.z) < 4.0 then
                wait = 5
                if not alotettu then
                    teksti(lol, tostring("~g~E ~w~- juttele!"))
                    if IsControlJustReleased(0, 38) then
                        menu()
                    end
                else
                    teksti(lol, tostring("~w~Hae ~r~ajoneuvo ~w~- !"))
                end
            end  
        end
        Wait(wait)
    end
end)


function menu()
    local elements = {}
    table.insert(elements, {label = '<span style = "color:red;">Tuontiauto</span>', value = 1})
    ESX.UI.Menu.Open(
	    'default', GetCurrentResourceName(), 'tuontiauto',
	    {
	        title    = 'tuontiauto',
	        align    = 'bottom',
	        elements = elements, 
	    },
		function(data, menu)
            menu.close()
            ClearPedTasks(PlayerPedId())
            ESX.TriggerServerCallback('karpo_tuontiauto:boliseja', function(bolis,cooldown,aktiivinen)
                if bolis >= Config.boliiseja then
                    if cooldown <= 0 then
                        if aktiivinen == 0 then
                            alota()
                        else
                            ESX.ShowNotification('Joku vetää jo tuontiautoa!')
                        end
                    else
                        ESX.ShowNotification('Cooldown menossa!')
                    end
                else
                    ESX.ShowNotification('Ei tarpeeksi poliiseja!')
                end
            end)
        end,
	function(data, menu)  
		menu.close()
	end
)
end

function alota()
    spawnattu = false
    alotettu = true
    TriggerServerEvent('karpo_tuontiauto:aktiivinen', 1)
    local mistautorandom = math.random(1,#hakumestat) --hakee random mestan ylemmästä paskasta
    timeri(mistautorandom)
    mistauto = hakumestat[mistautorandom]
    --random blip shittii
    hakublip = AddBlipForCoord(mistauto.coords)
    SetBlipSprite (hakublip, 326)
    SetBlipColour (hakublip, 57)
    SetBlipAsShortRange(hakublip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Hakupiste')
    EndTextCommandSetBlipName(hakublip)
    SetBlipFlashes(hakublip, true)
    SetNewWaypoint(mistauto.coords)
    --auton spawni
    local x,y,z = table.unpack(mistauto.coords)
    local x2,y2,z2 = table.unpack(GetEntityCoords(PlayerPedId()))
    CreateThread(function()
        while true do
            local coords22 = GetEntityCoords(PlayerPedId())
            if alotettu then
                if not spawnattu then
                    if Vdist(coords22.x, coords22.y, coords22.z, mistauto.coords) < 150.0 then --spawnataa vastku lähel, ettei despawnaa
                        kaara = hakumestat[mistautorandom].auto
                        local hash = GetHashKey(kaara)
                        RequestModel(hash)
                        while not HasModelLoaded(hash) do
                            RequestModel(hash)
                            Citizen.Wait(1)
                        end
                        car = CreateVehicle(hash, mistauto.coords, 230.83, true, false)
                        SetVehicleDoorsLocked(car, 2)
                        kilpi = 'AUTO' .. math.random(100, 999)
                        SetVehicleNumberPlateText(car, kilpi)
                        spawnattu = true
                        break --rikotaan loop koska ei tarvita mihkää
                    end
                end
            end
            Wait(3500)
        end
    end)
    CreateThread(function()
        while true do
            local coords22 = GetEntityCoords(PlayerPedId())
            local wait2 = 2000
            if Vdist(coords22.x, coords22.y, coords22.z, mistauto.coords) < 3.0 then
                wait2 = 5
                if not tiirikoi and alotettu and not autossa then
                    teksti(mistauto.coords, tostring("~r~E ~w~- tiirikoi!"))
                    if IsControlJustReleased(0, 38) then
                        if not tiirikoi then --kunnon spaghetti koodia vittu
                            tiirikoi = true
                            TriggerServerEvent('karpo_tuontiauto:ilmotus', 1)
                            TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 500)
                            Wait(Config.tiirikointiaika*1000)
                            tiirikoitu()
                            break
                        else
                            if not autossa then
                                teksti(mistauto.coords, tostring("~w~Tiirikoidaan ~r~- !"))
                            end
                        end
                    end
                end
            end
            Wait(wait2)
        end
    end)
end

function tiirikoitu()
    SetVehicleDoorsLocked(car, 1)
    tiirikoi = false
    autossa = true
    ClearPedTasks(PlayerPedId())
    RemoveBlip(hakublip)
    local myyntipaikka = math.random(1,#myyntimestat)
    local paikka = myyntimestat[myyntipaikka]
    local maksa = myyntimestat[myyntipaikka].hinta
    myyntiblip = AddBlipForCoord(paikka.coords)
    SetBlipSprite (myyntiblip, 500)
    SetBlipColour (myyntiblip, 57)
    SetBlipAsShortRange(myyntiblip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Myyntipiste')
    EndTextCommandSetBlipName(myyntiblip)
    SetNewWaypoint(paikka.coords)
    ESX.ShowNotification('Myy ajoneuvo GPS-sijainnille!')
    myymassa = true
    CreateThread(function()
        while true do
            local wait3 = 1000
            local homo = GetEntityCoords(PlayerPedId())
            if Vdist(homo.x, homo.y, homo.z, paikka.coords) < 3.0 then
                wait3 = 5
                if not myyty then
                    if IsPedInAnyVehicle(PlayerPedId()) then
                        teksti(paikka.coords, tostring("~g~E ~w~myy ajoneuvo!"))
                        local munauto = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                        local rekkari = GetVehicleNumberPlateText(munauto)
                        if IsControlJustReleased(0, 38) then
                            if GetVehiclePedIsIn(PlayerPedId(), false) == car then
                                TriggerServerEvent('karpo_tuontiauto:myyauto', maksa)
                                TriggerServerEvent('karpo_tuontiauto:ilmotus', 3)
                                TriggerServerEvent('karpo_tuontiauto:aktiivinen', 0)
                                ESX.ShowNotification('Ajoneuvo myyty! Tienasit: ~g~$' ..maksa)
                                RemoveBlip(myyntiblip)
                                myyty = true
                                alotettu = false
                                break
                                Wait(10000)
                                TriggerServerEvent('karpo_tuontiauto:loppupoliisi')
                            else
                                ESX.ShowNotification('Eihän tää ole edes oikea auto??')
                            end
                        end
                    end
                end
            end
            Wait(wait3)
        end
    end)
end


function timeri(perse)
    local aika22 = hakumestat[perse].aika
    CreateThread(function()
        while aika22 > 0 do
            Wait(1000)
            if aika22 > 0 then
                aika22 = aika22 - 1
            end
        end
     end)
    CreateThread(function()
        while true do
            Wait(2)
            if not autossa and alotettu then
                teksti(GetEntityCoords(PlayerPedId()), '~w~Aika [~g~'..aika22..'~w~]')
            end
            if not autossa and alotettu then
                if IsPedDeadOrDying(PlayerPedId()) then
                    alotettu = false
                    autossa = false
                    TriggerServerEvent('karpo_tuontiauto:aktiivinen', 0)
                    RemoveBlip(hakublip)
                    ESX.ShowNotification('Varkaus epäonnistui!')
                    break
                end
            end
            if aika22 <= 0 and not autossa and alotettu then
                alotettu = false
                ESX.ShowNotification('Aika loppui!')
                TriggerServerEvent('karpo_tuontiauto:aktiivinen', 0)
                break
            end
        end
    end)
    CreateThread(function()
        while true do
            Wait(Config.blipaika*1000)
            if autossa and alotettu then
                local munauto = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                local rekkari = GetVehicleNumberPlateText(munauto)
                if GetVehiclePedIsIn(PlayerPedId(), false) == car then
                    local coords = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('karpo_tuontiauto:poliisiblip', coords.x, coords.y, coords.z)
                end
            end
        end
    end)
end


RegisterNetEvent('karpo_tuontiauto:clienttiin')
AddEventHandler('karpo_tuontiauto:clienttiin', function(infot)
    perse = infot
end)

RegisterNetEvent('karpo_tuontiauto:ilmotus')
AddEventHandler('karpo_tuontiauto:ilmotus', function(lolz)
    PlaySound(-1, "Hang_Up", "Phone_SoundSet_Michael", 0, 0, 1)
    if lolz == 1 then
	    ESX.ShowAdvancedNotification('Tuontiauto', 'Hälytys laukaistu!', "", "CHAR_CALL911", 1)
    elseif lolz == 2 then
        RemoveBlip(blip)
        ESX.ShowAdvancedNotification('Tuontiauto', 'Varkaus peruuntui!', "", "CHAR_CALL911", 1)
    elseif lolz == 3 then
        RemoveBlip(blip)
        ESX.ShowAdvancedNotification('Tuontiauto', 'Varkaus onnistui!', "", "CHAR_CALL911", 1)
    end
end)

RegisterNetEvent('karpo_tuontiauto:blipclient')
AddEventHandler('karpo_tuontiauto:blipclient', function(x,y,z)
    RemoveBlip(blip)
    blip = AddBlipForCoord(x,y,z)
    SetBlipSprite(blip , 326)
    SetBlipScale(blip , 1.0)
    SetBlipColour(blip, 8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Tuontiauto')
    EndTextCommandSetBlipName(blip)
    SetBlipFlashes(blip, true)
end)

RegisterNetEvent('karpo_tuontiauto:poisblip')
AddEventHandler('karpo_tuontiauto:poisblip', function()
	RemoveBlip(blip)
end)


function teksti(cordinaatit, teksti)
	local onScreen, x, y = World3dToScreen2d(cordinaatit.x, cordinaatit.y, cordinaatit.z+0.20)
	SetTextScale(0.41, 0.41)
	SetTextOutline()
	SetTextDropShadow()
	SetTextDropshadow(2, 0, 0, 0, 255)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 255)
	AddTextComponentString(teksti)
	DrawText(x, y)
    local factor = (string.len(teksti)) / 400
    if Config.tausta3dhen then
        DrawRect(x, y+0.012, 0.015+ factor, 0.03, 0, 0, 0, 68)
    end
end
