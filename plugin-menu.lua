function init(plugin)
    plugin:newMenuGroup{
      id = "PixthicTools",
      title = "Pixthic Tools",
      group = "edit_insert"
    }
  
    plugin:newCommand{
      id = "Pixthic_Perspective_Grid",
      title = "Isometric Grid Generator",
      group = "PixthicTools",
      onclick = function()
        local path = app.fs.joinPath(app.fs.userConfigPath, "extensions", "pixthic", "perspectivegrid.lua")
        local gridScript = dofile(path)
        if gridScript and gridScript.showPixthicDialog then
          gridScript.showPixthicDialog()
        end
      end
    }
  
    plugin:newCommand{
      id = "Pixthic_Layer_Color_Label",
      title = "Layer Color Label",
      group = "PixthicTools",
      onclick = function()
        local path = app.fs.joinPath(app.fs.userConfigPath, "extensions", "pixthic", "layercolorlabel.lua")
        local mod = dofile(path)
        if mod and mod.showLayerColorLabel then
          mod.showLayerColorLabel()
        end
      end
    }
  end