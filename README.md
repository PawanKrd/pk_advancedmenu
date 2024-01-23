## Pawan.Krd Scripts

pk_advancedmenu is a new and innovative menu system designed for interacting with game entities. It's an easy-to-use interface that can be navigated with both a mouse and a keyboard.

Features:
* Navigate through menu options using your mouse wheel or the arrow keys on your keyboard.
* Select options using either a left mouse click, space bar, E button, or Enter button.

***Vehicle door menu is included with the script***

Here’s an example of how to create a menu using this script:

```lua
menuData = nil
menuData = pk_advancedmenu:CreateMenu({
    title = "Example Menu",
    options = {
        {
            title = "Option 1",
            action = function()
                print("Option 1 selected")
            end
        },
        {
            title = "Option 2",
            action = function()
                print("Option 2 selected")
            end
        },
        {
            title = "Option 3",
            action = function()
                print("Option 3 selected")
            end
        },
    },
    coords = {x = -661.0857, y = -1644.2106, z = 25.1675},
    data = menuData
})
```
Download it here: [Download pk_advancedmenu](https://github.com/PawanKrd/pk_advancedmenu)
Watch a preview: [Preview Video](https://youtu.be/IMxZBE0yuJs)

## Performance Note
The resource's performance is currently limited as it runs inside an infinite while loop. Suggestions and pull requests to improve its performance are welcome.
