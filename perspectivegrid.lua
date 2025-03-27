local dlg = Dialog("Isometric Grid Generator")

-- User Interface

dlg:number{
    id="gridWidth",
    label="Grid Width",
    text="32",
    decimals=0,
    min=8,
    max=128
}

dlg:number{
    id="gridHeight",
    label="Grid Height",
    text="16",
    decimals=0,
    min=8,
    max=128
}

dlg:color{
    id="gridColor",
    label="Grid Color",
    color=Color(255, 0, 255, 255)
}

dlg:slider{
    id="gridOpacity",
    label="Opacity",
    min=0,
    max=255,
    value=255
}

-- Bresenham line algorithm for drawing
local function draw_line(image, x1, y1, x2, y2, color)
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy

    while true do
        if x1 >= 0 and x1 < image.width and y1 >= 0 and y1 < image.height then
            image:putPixel(x1, y1, color)
        end
        if x1 == x2 and y1 == y2 then break end
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x1 = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1 = y1 + sy
        end
    end
end

-- Grid generation button
dlg:button{
    id="generate",
    text="Generate Grid",
    onclick=function()
        local sprite = app.activeSprite
        
        if not sprite then
            app.alert("You must open a sprite first!")
            return
        end

        local gridWidth = tonumber(dlg.data.gridWidth)
        local gridHeight = tonumber(dlg.data.gridHeight)

        local gridColor = dlg.data.gridColor
        local opacity = tonumber(dlg.data.gridOpacity)
        local color = Color(gridColor.red, gridColor.green, gridColor.blue, opacity)

        local layer = nil
        for _, l in ipairs(sprite.layers) do
            if l.name == "Isometric Grid" then
                layer = l
                break
            end
        end
        if not layer then
            layer = sprite:newLayer()
            layer.name = "Isometric Grid"
        end

        local image = Image(sprite.width, sprite.height, ColorMode.RGB)
        local cel = sprite:newCel(layer, 1)
        cel.image = image
        cel.position = Point(0, 0)

        -- **Draw the isometric grid in block formation**
        for y = 0, sprite.height, gridHeight do
            for x = 0, sprite.width, gridWidth do
                local x1, y1 = x, y
                local x2, y2 = x + gridWidth, y + gridHeight

                -- Left diagonal line
                draw_line(image, x1, y1, x1 + gridWidth, y1 - gridHeight, color)

                -- Right diagonal line
                draw_line(image, x1, y1, x1 - gridWidth, y1 - gridHeight, color)
            end
        end

        cel.image = image
        app.refresh()
    end
}

dlg:button{text="Close", onclick=function() dlg:close() end}

function showPixthicDialog()
    dlg:show()
end

return {
    showPixthicDialog = showPixthicDialog
}