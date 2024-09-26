--[[
MIT LICENSE
Copyright © 2024 Gabriel Carvalho [oakgc]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

######################################
Author: Gabriel Carvalho
Last Update: September/2024
Release Updates:
    Version 1.0 (09/24)
        First version of the extension.
######################################

]]
-- Turn of warnings of Aseprite API methods
---@diagnostic disable: undefined-global
---@diagnostic disable: lowercase-global
-------------------------------
-- GLOBAL VARIABLES
-------------------------------
    defaultScaleGrid = 2 
    minSizeGrid = 2  
    decreaseGrid = "decrease"
    increaseGrid = "increase"
    divisorString = "|"
    preferences = {}
-------------------------------
--TEXT VARIABLES
-------------------------------
    txtKeywords = "Decrease Grid     -- Alt + PageDown | Increase Grid     -- Alt + Pageup"
    txtAlertSprite = "Please open a sprite or create a new one to use this extension"
    txtAlertGrid = "Error: It`s impossible to shrink more the grid size."
    
--Check if has a current sprite open
local function VerifySpriteIsOpened(sprite)
    if not sprite then
        app.alert {
            title = "No find an Active Sprite!!!",
            text = txtAlert
        }
    end
    return sprite
end

--Get the currentSprite is opened
local function GetCurrentSprite()
    local sprite
    sprite = app.sprite
    return sprite
end
--Get the grid Bound information of current Sprite
local function GetCurrentGrid(sprite)
    local currentGrid
    if sprite then
        currentGrid = sprite.gridBounds
    end 
    return currentGrid
end

--Receive the last scale the user defined
local function GetUserLastScaleDefined(plugin)
    preferences = plugin.preferences
    --if preferences is empty set the default Scale (2x)
    if preferences.ScaleGrid == nil then
        scaleGrid = defaultScaleGrid 
    else
        scaleGrid = preferences.ScaleGrid
    end
end    

--Save the scale the user defined
local function SetUserLastScaleDefined(plugin)
    plugin.preferences = preferences
end

-- First checking that is necesssary to execute the commands
local function PreparationsToStart()
    --current sprite
    currentSprite = GetCurrentSprite()
    VerifySpriteIsOpened(currentSprite)
    --get grid
    grid = GetCurrentGrid(currentSprite)
end

--Draw the limits of the grid Bounds
local function DrawGridBounds(grid,sprite)
    sprite.gridBounds = Rectangle(grid.x,grid.y,grid.width,grid.height)
end

--Change the dimension of grid to increase the size
local function DecreaseGridDimensions(grid,scale)
    grid.width = grid.width//scale
    grid.height = grid.height//scale
    return grid.width,grid.height
end

--Change the dimension of grid to decrease the size
local function IncreaseGridDimensions(grid,scale)
    grid.width = grid.width*scale
    grid.height = grid.height*scale
    return grid.width,grid.height
end
    
--Check what type will be used to resize the Grid
local function ResizeGridBounds(mode,grid,scale,sprite)
    if mode == decreaseGrid then
        grid.width,grid.height = DecreaseGridDimensions(grid,scale)
        if (grid.width or grid.height) <= minSizeGrid then
            app.alert(txtAlertGrid)
            return 
        end
    elseif mode == increaseGrid then
        grid.width,grid.height = IncreaseGridDimensions(grid,scale)
    end    
    DrawGridBounds(grid,sprite)
end

--Draw the main dialog window
local function DrawDialogSettings(grid,currentSprite)
 GridDlg = Dialog("Resize Grid")
    :label {text = "Scale:"}
    :newrow()
    GridDlg:slider{
            id ="slideScale",
            min = 1,
            max = 10,
            value = scaleGrid,
            onrelease = function()
                scaleGrid = GridDlg.data.slideScale
                preferences.ScaleGrid = GridDlg.data.slideScale
            end
    }
    :button{
        id = "buttonReset",
        text ="Reset Scale(2x)",
        onclick= function()
            scaleGrid = defaultScaleGrid
            GridDlg:modify{id="slideScale",value = defaultScaleGrid}
        end
    }    
    :separator()
    :label{
        id ="txtMenuKeys",
        text = "SHORTCUTS"
    }
    :newrow()
    :label{
        id ="txtDecreaseKeys",
        text = string.sub(txtKeywords,1,string.find(txtKeywords,divisorString)-1)
    }
    :newrow()
    :label{
        id ="txtIncreaseKeys",
        text = string.sub(txtKeywords,string.find(txtKeywords,divisorString)+2,string.len(txtKeywords))
    }
    :separator()
    :label{
        id ="txtMenuButtons",
        text = "TEST NEW SCALES"
    }
    :button{
        id = "buttonDecrease",
        text ="Decrease Grid",
        onclick = function ()  
            ResizeGridBounds(decreaseGrid,grid,scaleGrid,currentSprite)
        end
    }
    :button{
        id = "buttonIncrease",
        text ="Increase Grid",
        onclick = function()
            ResizeGridBounds(increaseGrid,grid,scaleGrid,currentSprite)
        end
    }
    :show()
end    

--Include the access to this extension in View Menu
local function ImportResizeGridInMenu(plugin)
    plugin:newMenuGroup{
        id ="resize-grid-menu",
        title ="Resize Grid",
        group = "view_canvas_helpers"
    }
    plugin:newCommand{
        id ="resize-grid-increase",
        title = "Increase Grid",
        group = "resize-grid-menu",
        onclick = function ()
            PreparationsToStart()
            if currentSprite == nil then
                return 
            end
            ResizeGridBounds(increaseGrid,grid,scaleGrid,currentSprite)
        end
    }
    plugin:newCommand{
        id = "resize-grid-decrease",
        title = "Decrease Grid",
        group = "resize-grid-menu",
        onclick = function ()
            PreparationsToStart()
            if currentSprite == nil then
                return 
            end
            ResizeGridBounds(decreaseGrid,grid,scaleGrid,currentSprite)
        end
    }
    plugin:newMenuSeparator{
        group = "resize-grid-menu"
    }
    plugin:newCommand {
        id = "resize-grid",
        title = "Settings",
        group = "resize-grid-menu",   
        onclick = function ()
            PreparationsToStart()
            if currentSprite == nil then
                return 
            end
            DrawDialogSettings(grid,currentSprite)
        end
    }
end
--Initialize the extension 
function init(plugin)
    GetUserLastScaleDefined(plugin)
    ImportResizeGridInMenu(plugin)
end

--Finalize the extension
function exit(plugin)
   SetUserLastScaleDefined(plugin)
end

