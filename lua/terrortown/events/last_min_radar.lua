if SERVER then
    AddCSLuaFile()

    resource.AddFile("materials/vgui/ttt/vskin/events/game.vmt")
end

if CLIENT then
    EVENT.title = "title_last_min_radar"
    EVENT.icon = Material("vgui/ttt/vskin/events/game.vmt")
	
    function EVENT:GetText()
		return {
			{
				string = "last_min_radar_desc",
				params = {
					t = GetConVar("ttt2_last_min_radar_timeout"):GetInt(),
					n = GetConVar("ttt2_last_min_radar_min_plys"):GetInt()
				},
				translateParams = true
			}
		}
    end
end

if SERVER then
    function EVENT:Trigger()
        return self:Add({
            serialname = self.event.title
        })
    end
end

function EVENT:Serialize()
    return self.event.serialname
end