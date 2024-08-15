local PLUGIN = PLUGIN

PLUGIN.name = "Breakdownable Items"
PLUGIN.description = "Allows items to be broken down into other items."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"

PLUGIN.readme = [[
This plugin allows items to be broken down into other items. This is useful for crafting systems where you want to be able to break down items into their components.

To make an item breakdownable, you need to use the ITEM:MakeSalvageable function. Here is an example of how to use it:

ITEM.name = "NAME"
ITEM.description = "DESCRIPTION"
ITEM.model = "MODEL"

ITEM:MakeSalvageable({
    "ITEM1",
    "ITEM2",
    "ITEM3",
}, {
    "SOUND1",
    "SOUND2",
    "SOUND3",
}, "ATTRIBUTE", 0.1, "EFFECT")

Replace the placeholders with the appropriate values. The first argument is a table of items that the item will break down into. The second argument is a table of sounds that will be played when the item is broken down. The third argument is the attribute that will be updated when the item is broken down. The fourth argument is the amount that the attribute will be updated by. The fifth argument is the effect that will be played when the item is broken down.

Here is an example of how to use the ITEM:MakeSalvageable function:

ITEM:MakeSalvageable({
    "scrap_metal",
    "scrap_metal",
    "scrap_metal",
}, {
    "physics/plastic/plastic_barrel_break1.wav",
    "physics/plastic/plastic_barrel_break2.wav",
    "physics/plastic/plastic_barrel_break3.wav",
}, "crafting", 0.1, "Explosion")

This will make the item break down into three scrap metal items and play a random plastic barrel break sound when it is broken down. It will also update the crafting attribute by 0.1 and play the explosion effect when it is broken down.

Here is a more simplified example:

ITEM:MakeSalvageable({
    "scrap_metal",
})

This will make the item break down into one scrap metal item.

Make sure to include this function in the item's item file. If you do not include this function, the item will not be breakable.
]]