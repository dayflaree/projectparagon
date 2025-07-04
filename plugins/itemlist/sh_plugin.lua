local PLUGIN = PLUGIN

PLUGIN.name = "Admin Item Spawnmenu"
PLUGIN.author = "Unknown"
PLUGIN.description = "Adds a spawn-menu tab with all registered items listed by category."

if ( SERVER ) then
    netstream.Hook("MenuItemSpawn", function(ply, uniqueID)
        if not ( IsValid(ply) ) then return end
        if not ( ply:IsAdmin() ) then return end

        local pos = ply:GetEyeTraceNoCursor().HitPos

        ix.item.Spawn(uniqueID, pos + Vector( 0, 0, 10 ))
        ix.log.Add(ply, "itemListSpawnedItem", uniqueID)

        hook.Run("PlayerSpawnedItem", ply, pos, uniqueID)
    end)

    netstream.Hook("MenuItemGive", function(ply, uniqueID, amount)
        if not ( IsValid(ply) ) then return end
        if not ( ply:IsAdmin() ) then return end

        local character = ply:GetCharacter()
        local inventory = character:GetInventory()

        inventory:Add(uniqueID, amount)
        ix.log.Add(ply, "itemListGiveItem", uniqueID)

        hook.Run("PlayerGaveItem", ply, ply:GetCharacter(), uniqueID, 1)
    end)

    function PLUGIN:PlayerLoadedCharacter(ply)
        netstream.Start(ply, "CheckForItemTab")
    end

    ix.log.AddType("itemListSpawnedItem", function(ply, name)
        return string.format("%s has spawned a %s.", ply:GetName(), name)
    end)
    ix.log.AddType("itemListGiveItem", function(ply, name)
        return string.format("%s has given himself a %s.", ply:GetName(), name)
    end)
else
    local icons = {
        ["Ammo"] = "box",
        ["Clothing"] = "user_suit",
        ["Consumeables"] = "cake",
        ["Junk"] = "bin",
        ["Medical Items"] = "heart",
        ["misc"] = "brick",
        ["Weapons"] = "gun",
        ["Tools"] = "wrench",
    }

    spawnmenu.AddContentType("ixItem", function(container, data)
        if not ( data.name ) then return end

        local icon = vgui.Create("ContentIcon", container)

        icon:SetContentType("ixItem")
        icon:SetSpawnName(data.uniqueID)
        icon:SetName(data.name)

        icon.model = vgui.Create("ModelImage", icon)
        icon.model:SetMouseInputEnabled(false)
        icon.model:SetKeyboardInputEnabled(false)
        icon.model:StretchToParent(16, 16, 16, 16)
        icon.model:SetModel(data:GetModel(), data:GetSkin(), "000000000")
        icon.model:MoveToBefore(icon.Image)

        function icon:DoClick()
            netstream.Start("MenuItemSpawn", data.uniqueID)
            surface.PlaySound("ui/buttonclickrelease.wav")
        end

        function icon:OpenMenu()
            local menu = DermaMenu()

            menu:AddOption("Copy Item ID to Clipboard", function()
                SetClipboardText(data.uniqueID)
            end)

            menu:AddOption("Give to yourself", function()
                netstream.Start("MenuItemGive", data.uniqueID, 1)
            end)

            menu:AddSpacer()

            for i = 1, 10 do
                menu:AddOption("Give "..i.." to yourself", function()
                    netstream.Start("MenuItemGive", data.uniqueID, i)
                end)
            end

            menu:Open()

            for _, v in pairs(menu:GetChildren()[1]:GetChildren()) do
                if ( v:GetClassName() == "Label" ) then
                    --v:SetFont("")
                end
            end
        end

        if ( IsValid(container) ) then
            container:Add(icon)
        end
    end)

    local function CreateItemsPanel()
        local base = vgui.Create("SpawnmenuContentPanel")
        local tree = base.ContentNavBar.Tree
        local categories = {}

        vgui.Create("ItemSearch", base.ContentNavBar)

        for _, v in SortedPairsByMemberValue(ix.item.list, "category") do
            if not ( categories[v.category] ) then
                categories[v.category] = true

                local category = tree:AddNode(v.category, icons[v.category] and ("icon16/" .. icons[v.category] .. ".png") or "icon16/brick.png")

                function category:DoPopulate()
                    if ( self.Container ) then return end

                    self.Container = vgui.Create("ContentContainer", base)
                    self.Container:SetVisible(false)
                    self.Container:SetTriggerSpawnlistChange(false)


                    for _, itemTable in SortedPairsByMemberValue(ix.item.list, "name") do
                        if ( itemTable.category == v.category and not string.match(itemTable.name, "Base") ) then
                            spawnmenu.CreateContentIcon("ixItem", self.Container, itemTable)
                        end
                    end
                end

                function category:DoClick()
                    self:DoPopulate()
                    base:SwitchPanel(self.Container)
                end
            end
        end

        local FirstNode = tree:Root():GetChildNode(0)

        if ( IsValid(FirstNode) ) then
            FirstNode:InternalDoClick()
        end

        PLUGIN:PopulateContent(base, tree, nil)

        return base
    end

    spawnmenu.AddCreationTab("Admin Item Spawnmenu", CreateItemsPanel, "icon16/script_key.png")

    netstream.Hook("CheckForItemTab", function()
        if not ( LocalPlayer():GetNWBool("spawnmenu_reloaded") ) then
            LocalPlayer():ConCommand("spawnmenu_reload")

            LocalPlayer():SetNWBool("spawnmenu_reloaded", true)
        end
    end)
end
