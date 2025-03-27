function init(plugin)
    plugin:newCommand{
        id = "Pixthic_Isometric_Grid",
        title = "Pixthic v1.1",
        group = "edit_insert",
        onclick = function()
            local gridScript = dofile(app.fs.joinPath(app.fs.userConfigPath, "extensions", "pixthic", "perspectivegrid.lua"))
            gridScript.showPixthicDialog()
        end
    }
end