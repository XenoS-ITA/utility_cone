DevMode(true)

Citizen.CreateThread(function()
    StartESX()
    
    CreateLoop(function()
        if xPlayer.job.name == "police" then
            local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 4.0, 0, 70)
            if vehicle ~= 0 then
                if GetVehicleDoorAngleRatio(vehicle, 5) > 0.4 then
                    if GetOnHandObject() == 0 then
                        DeleteMarker("delete_cone")
                        CreateMarker("get_cone", GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot')), 2.0, 2.0, "Press [~g~E~w~] to pick up an ~o~object~w~")
                    else
                        DeleteMarker("get_cone")
                        CreateMarker("delete_cone", GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot')), 2.0, 2.0, "Press [~g~E~w~] to deposit the ~o~object~w~")
                    end
                else
                    DeleteMarker("get_cone")
                end
            else
                DeleteMarker("get_cone")
                Citizen.Wait(500)
            end
        else
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
            elements = {
                {label = "Road Cone",	    value = 'prop_roadcone02a'},
            }
        }, function(data, menu)
            menu.close()
            TakeObjectOnHand(PlayerPedId(), data.current.value)
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