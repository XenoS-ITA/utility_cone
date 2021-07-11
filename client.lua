DevMode(false)

Citizen.CreateThread(function()
    StartESX()
    
    CreateLoop(function()
        local founded = false

        for k,v in pairs(Config.Jobs) do
            if xPlayer.job.name == k then
                founded = true

                local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 4.0, 0, 100703)
                if vehicle ~= 0 then
                    local vehicleModel = GetEntityModel(vehicle)

                    for i=1, #Config.Vehicle do
                        if vehicleModel == GetHashKey(Config.Vehicle[i]) then
                            if GetVehicleDoorAngleRatio(vehicle, 5) > 0.4 then
                                if GetOnHandObject() == 0 then
                                    DeleteMarker("delete_cone")

                                    if GetFrom("get_cone", "menu_elements") == nil then
                                        SetFor("get_cone", "menu_elements", v)
                                    end

                                    CreateMarker("get_cone", GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot')), 2.0, 2.0, "Press [~g~E~w~] to pick up an ~o~object~w~")
                                else
                                    DeleteMarker("get_cone")
                                    CreateMarker("delete_cone", GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot')), 2.0, 2.0, "Press [~g~E~w~] to deposit the ~o~object~w~")
                                end
                            else
                                DeleteMarker("get_cone")
                            end
                            
                            break
                        end
                    end
                else
                    DeleteMarker("get_cone")
                    Citizen.Wait(500)
                end
            end
        end

        if not founded then
            Citizen.Wait(2000)
        end
    end)
end)

On("marker", function(id)
    if id == "get_cone" then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'prop_spawn',
        {
            title    = 'Select the object',
            align    = 'top-left',
            elements = GetFrom("get_cone", "menu_elements")
        }, function(data, menu)
            menu.close()
            TakeObjectOnHand(PlayerPedId(), data.current.model)
        end, function(data, menu)
            menu.close()
        end)
    elseif string.find(id, "grab_cone") then
        if GetOnHandObject() ~= 0 then
            return
        end
    
        local obj = GetClosestObjectOfType(GetCoordOf("marker", id), 0.5, GetHashKey("prop_roadcone02a"))

        if obj ~= 0 then
            TakeObjectOnHand(PlayerPedId(), obj)
            DeleteMarker(id)
        end
    elseif id == "delete_cone" then
        DropObjectFromHand(GetOnHandObject(), true)
    end
end)

IsControlJustPressed("E", function()
    if GetOnHandObject() ~= 0 and GetDistanceFrom("marker", "delete_cone") > 3.0 then
        local savedObj = GetOnHandObject()

        DropObjectFromHand(savedObj, false)
        Citizen.Wait(300)
        CreateMarker("grab_cone_{r}", GetEntityCoords(savedObj), 3.5, 3.5, "Press [~g~E~w~] to pick up the ~o~object~w~")
    end
end)
