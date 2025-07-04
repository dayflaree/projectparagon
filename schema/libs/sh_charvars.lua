--- Default character vars
-- @classmod Character

--- Sets this character's name. This is automatically networked.
-- @realm server
-- @string name New name for the character
-- @function SetName

--- Returns this character's name
-- @realm shared
-- @treturn string This character's current name
-- @function GetName
ix.char.RegisterVar("name", {
    field = "name",
    fieldType = ix.type.string,
    default = "John SCP",
    index = 1,
    OnValidate = function(self, value, payload, client)
        if (!value) then
            return false, "invalid", "name"
        end

        value = tostring(value):gsub("\r\n", ""):gsub("\n", "")
        value = string.Trim(value)

        local minLength = ix.config.Get("minNameLength", 4)
        local maxLength = ix.config.Get("maxNameLength", 32)

        if (value:utf8len() < minLength) then
            return false, "nameMinLen", minLength
        elseif (!value:find("%S")) then
            return false, "invalid", "name"
        elseif (value:gsub("%s", ""):utf8len() > maxLength) then
            return false, "nameMaxLen", maxLength
        end

        return hook.Run("GetDefaultCharacterName", client, payload.faction) or value:utf8sub(1, 70)
    end,
    OnPostSetup = function(self, panel, payload)
        local faction = ix.faction.indices[payload.faction]
        local name, disabled = hook.Run("GetDefaultCharacterName", LocalPlayer(), payload.faction)

        if (name) then
            panel:SetText(name)
            payload:Set("name", name)
        end

        if (disabled) then
            panel:SetDisabled(true)
            panel:SetEditable(false)
        end

        panel:SetBackgroundColor(faction.color or Color(255, 255, 255, 25))
    end
})

--- Sets this character's physical description. This is automatically networked.
-- @realm server
-- @string description New description for this character
-- @function SetDescription

--- Returns this character's physical description.
-- @realm shared
-- @treturn string This character's current description
-- @function GetDescription
ix.char.RegisterVar("description", {
    field = "description",
    fieldType = ix.type.text,
    default = "",
    index = 2,
    OnValidate = function(self, value, payload)
        value = string.Trim((tostring(value):gsub("\r\n", ""):gsub("\n", "")))
        local minLength = ix.config.Get("minDescriptionLength", 16)

        if (value:utf8len() < minLength) then
            return false, "descMinLen", minLength
        elseif (!value:find("%s+") or !value:find("%S")) then
            return false, "invalid", "description"
        end

        return value
    end,
    OnPostSetup = function(self, panel, payload)
        panel:SetMultiline(true)
        panel:SetFont("ixMenuButtonFont")
        panel:SetTall(panel:GetTall() * 2 + 6) -- add another line
        panel.AllowInput = function(_, character)
            if (character == "\n" or character == "\r") then
                return true
            end
        end
    end,
    alias = "Desc"
})

--- Sets this character's model. This sets the player's current model to the given one, and saves it to the character.
-- It is automatically networked.
-- @realm server
-- @string model New model for the character
-- @function SetModel

--- Returns this character's model.
-- @realm shared
-- @treturn string This character's current model
-- @function GetModel
ix.char.RegisterVar("model", {
    field = "model",
    fieldType = ix.type.string,
    default = "models/error.mdl",
    index = 3,
    OnSet = function(character, value)
        local client = character:GetPlayer()

        if (IsValid(client) and client:GetCharacter() == character) then
            client:SetModel(value)
        end

        character.vars.model = value
    end,
    OnGet = function(character, default)
        return character.vars.model or default
    end,
    OnDisplay = function(self, container, payload)
        local scroll = container:Add("DScrollPanel")
        scroll:Dock(TOP) -- TODO: don't fill so we can allow other panels
        scroll:SetTall(256)
        scroll.Paint = function(panel, width, height)
            derma.SkinFunc("DrawImportantBackground", 0, 0, width, height, Color(255, 255, 255, 25))
        end

        local layout = scroll:Add("DIconLayout")
        layout:Dock(FILL)
        layout:SetSpaceX(1)
        layout:SetSpaceY(1)

        local faction = ix.faction.indices[payload.faction]

        if (faction) then
            local models = faction:GetModels(LocalPlayer())

            for k, v in SortedPairs(models) do
                local icon = layout:Add("ixSpawnIcon")
                icon:SetSize(128, 256)
                icon:InvalidateLayout(true)
                icon.DoClick = function(this)
                    payload:Set("model", k)
                end
                icon.PaintOver = function(this, w, h)
                    if (payload.model == k) then
                        local color = ix.config.Get("color", color_white)

                        surface.SetDrawColor(color.r, color.g, color.b, 200)

                        for i = 1, 3 do
                            local i2 = i * 2
                            surface.DrawOutlinedRect(i, i, w - i2, h - i2)
                        end
                    end
                end

                if (isstring(v)) then
                    icon:SetModel(v)
                else
                    icon:SetModel(v[1], v[2] or 0, v[3])
                end
            end
        end

        return scroll
    end,
    OnValidate = function(self, value, payload, client)
        local faction = ix.faction.indices[payload.faction]

        if (faction) then
            local models = faction:GetModels(client)

            if (!payload.model or !models[payload.model]) then
                return false, "needModel"
            end
        else
            return false, "needModel"
        end
    end,
    OnAdjust = function(self, client, data, value, newData)
        local faction = ix.faction.indices[data.faction]

        if (faction) then
            local model = faction:GetModels(client)[value]

            if (isstring(model)) then
                newData.model = model
            elseif (istable(model)) then
                newData.model = model[1]

                -- save skin/bodygroups to character data
                local bodygroups = {}

                for i = 1, #model[3] do
                    bodygroups[i - 1] = tonumber(model[3][i]) or 0
                end

                newData.data = newData.data or {}
                newData.data.skin = model[2] or 0
                newData.data.groups = bodygroups
            end
        end
    end,
    ShouldDisplay = function(self, container, payload)
        local faction = ix.faction.indices[payload.faction]
        return #faction:GetModels(LocalPlayer()) > 1
    end
})

-- SetClass shouldn't be used here, character:JoinClass should be used instead

--- Returns this character's current class.
-- @realm shared
-- @treturn number Index of the class this character is in
-- @function GetClass
ix.char.RegisterVar("class", {
    bNoDisplay = true,
})

--- Sets this character's faction. Note that this doesn't do the initial setup for the player after the faction has been
-- changed, so you'll have to update some character vars manually.
-- @realm server
-- @number faction Index of the faction to transfer this character to
-- @function SetFaction

--- Returns this character's faction.
-- @realm shared
-- @treturn number Index of the faction this character is currently in
-- @function GetFaction
ix.char.RegisterVar("faction", {
    field = "faction",
    fieldType = ix.type.string,
    default = "Citizen",
    bNoDisplay = true,
    FilterValues = function(self)
        -- make sequential table of faction unique IDs
        local values = {}

        for k, v in ipairs(ix.faction.indices) do
            values[k] = v.uniqueID
        end

        return values
    end,
    OnSet = function(self, value)
        local client = self:GetPlayer()

        if (IsValid(client)) then
            self.vars.faction = ix.faction.indices[value] and ix.faction.indices[value].uniqueID

            client:SetTeam(value)

            -- @todo refactor networking of character vars so this doesn't need to be repeated on every OnSet override
            net.Start("ixCharacterVarChanged")
                net.WriteUInt(self:GetID(), 32)
                net.WriteString("faction")
                net.WriteType(self.vars.faction)
            net.Broadcast()
        end
    end,
    OnGet = function(self, default)
        local faction = ix.faction.teams[self.vars.faction]

        return faction and faction.index or 0
    end,
    OnValidate = function(self, index, data, client)
        if (index and client:HasWhitelist(index)) then
            return true
        end

        return false
    end,
    OnAdjust = function(self, client, data, value, newData)
        newData.faction = ix.faction.indices[value].uniqueID
    end
})

-- attribute manipulation should be done with methods from the ix.attributes library
ix.char.RegisterVar("attributes", {
    field = "attributes",
    fieldType = ix.type.text,
    default = {},
    index = 4,
    category = "attributes",
    isLocal = true,
    OnDisplay = function(self, container, payload)
        local maximum = hook.Run("GetDefaultAttributePoints", LocalPlayer(), payload) or 10

        if (maximum < 1) then
            return
        end

        local attributes = container:Add("DPanel")
        attributes:Dock(TOP)

        local y
        local total = 0

        payload.attributes = {}

        -- total spendable attribute points
        local totalBar = attributes:Add("ixAttributeBar")
        totalBar:SetMax(maximum)
        totalBar:SetValue(maximum)
        totalBar:Dock(TOP)
        totalBar:DockMargin(2, 2, 2, 2)
        totalBar:SetText(L("attribPointsLeft"))
        totalBar:SetReadOnly(true)
        totalBar:SetColor(Color(20, 120, 20, 255))

        y = totalBar:GetTall() + 4

        for k, v in SortedPairsByMemberValue(ix.attributes.list, "name") do
            payload.attributes[k] = 0

            local bar = attributes:Add("ixAttributeBar")
            bar:SetMax(maximum)
            bar:Dock(TOP)
            bar:DockMargin(2, 2, 2, 2)
            bar:SetText(L(v.name))
            bar.OnChanged = function(this, difference)
                if ((total + difference) > maximum) then
                    return false
                end

                total = total + difference
                payload.attributes[k] = payload.attributes[k] + difference

                totalBar:SetValue(totalBar.value - difference)
            end

            if (v.noStartBonus) then
                bar:SetReadOnly()
            end

            y = y + bar:GetTall() + 4
        end

        attributes:SetTall(y)
        return attributes
    end,
    OnValidate = function(self, value, data, client)
        if (value != nil) then
            if (istable(value)) then
                local count = 0

                for _, v in pairs(value) do
                    count = count + v
                end

                if (count > (hook.Run("GetDefaultAttributePoints", client, count) or 10)) then
                    return false, "unknownError"
                end
            else
                return false, "unknownError"
            end
        end
    end,
    ShouldDisplay = function(self, container, payload)
        return !table.IsEmpty(ix.attributes.list)
    end
})

--- Sets this character's current money. Money is only networked to the player that owns this character.
-- @realm server
-- @number money New amount of money this character should have
-- @function SetMoney

--- Returns this character's money. This is only valid on the server and the owning client.
-- @realm shared
-- @treturn number Current money of this character
-- @function GetMoney
ix.char.RegisterVar("money", {
    field = "money",
    fieldType = ix.type.number,
    default = 0,
    isLocal = true,
    bNoDisplay = true
})