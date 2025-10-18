local spr = app.activeSprite
if not spr then return app.alert("You must open a sprite first!") end

-- ==== Helpers ====
local function supportsLayerColor(layer) return pcall(function() local _=layer.color end) end
local function setLayerColorSafe(layer,c) pcall(function() layer.color=c end) end
local function clearLayerColorSafe(layer) pcall(function() layer.color=Color{r=0,g=0,b=0,a=0} end) end
local function isGroup(layer) local ok,val=pcall(function() return layer.isGroup end); return ok and val end
local function iterChildren(layer,fn) if isGroup(layer) then for _,cl in ipairs(layer.layers) do fn(cl); iterChildren(cl,fn) end end end

local function targets()
  local r = app.range or {}
  local ls = r.layers or {}
  if ls and #ls > 0 then return ls end
  if app.activeLayer then return { app.activeLayer } end
  return {}
end

local function allLayers()
  local list = {}
  local function walk(ly) list[#list+1]=ly; if isGroup(ly) then for _,cl in ipairs(ly.layers) do walk(cl) end end end
  for _,ly in ipairs(spr.layers) do walk(ly) end; return list
end
local function getLayerColor(layer) local ok,c=pcall(function() return layer.color end); if ok then return c end end
local function sameRGBA(a,b)
  if not a or not b then return false end
  local ok1, ar,ag,ab,aa = pcall(function() return a.red,a.green,a.blue,a.alpha end)
  local ok2, br,bg,bb,ba = pcall(function() return b.red,b.green,b.blue,b.alpha end)
  return ok1 and ok2 and ar==br and ag==bg and ab==bb and aa==ba
end
local function setVisibleSafe(layer,v) pcall(function() layer.isVisible=v end) end
local function setEditableSafe(layer,v) pcall(function() layer.isEditable=v end) end

do
  local any=false
  for _,ly in ipairs(targets()) do if supportsLayerColor(ly) then any=true; break end end
  if not any then return app.alert("layer.color is not available") end
end

local PRESETS = {
  {name="Mint",    col=Color{ r=180, g=235, b=210, a=255 }},
  {name="Sky",     col=Color{ r=170, g=210, b=255, a=255 }},
  {name="Peach",   col=Color{ r=255, g=200, b=175, a=255 }},
  {name="Lavender",col=Color{ r=215, g=190, b=250, a=255 }},
  {name="Butter",  col=Color{ r=255, g=245, b=180, a=255 }},
}

local function applySet(chosen, applyChildren)
  if not chosen then return end
  app.transaction(function()
    local function paint(ly)
      if supportsLayerColor(ly) then setLayerColorSafe(ly, chosen) end
      if applyChildren and isGroup(ly) then
        iterChildren(ly, function(cl) if supportsLayerColor(cl) then setLayerColorSafe(cl, chosen) end end)
      end
    end
    for _,ly in ipairs(targets()) do paint(ly) end
  end)
  app.refresh()
end

-- ==== UI ====
local dlg = Dialog{ title="LayerColor Pro" }
dlg:color{ id="col", label="Color", color=app.fgColor }
dlg:check{ id="applyToChildren", text="Apply to child layers (groups)", selected=true }
dlg:separator{ text="Presets (click a color)" }

local SW_W, SW_H = 140, 30

local function safeStrokeRect(ctx, x,y,w,h)
  local ok = pcall(function() ctx:strokeRect(x,y,w,h) end)
  if ok then return end
  ctx:fillRect(x,y,w,1); ctx:fillRect(x,y+h-1,w,1); ctx:fillRect(x,y,1,h); ctx:fillRect(x+w-1,y,1,h)
end

local function textColorFor(c)
  local L = 0.2126*c.red + 0.7152*c.green + 0.0722*c.blue
  if L < 140 then return Color{r=240,g=240,b=240,a=255} else return Color{r=20,g=20,b=20,a=255} end
end

for i,p in ipairs(PRESETS) do
  local cid = "sw_"..p.name
  dlg:canvas{
    id=cid, width=SW_W, height=SW_H,
    onpaint=function(ev)
      local ctx = ev.context
      ctx.color = Color{ r=24,g=24,b=24,a=255 }; safeStrokeRect(ctx, 0,0, SW_W,SW_H)
      ctx.color = p.col; ctx:fillRect(1,1, SW_W-2, SW_H-2)
      local txtCol = textColorFor(p.col)
      local ok = pcall(function()
        ctx:drawText{ text=p.name, color=txtCol, x=math.floor(SW_W/2), y=math.floor(SW_H/2), align="center" }
      end)
      if not ok then
        ctx.color = txtCol
        pcall(function() ctx:drawText{ text=p.name, color=txtCol, x=8, y=math.floor(SW_H/2-4) } end)
      end
    end,
    onmousedown=function(ev)
      if ev.button==nil or ev.button==1 then
        dlg:modify{ id="col", color=p.col }
        local d = dlg.data or {}
        d.col = p.col
        applySet(p.col, d.applyToChildren == nil and true or d.applyToChildren)
      end
    end,
    onclick=function()
      dlg:modify{ id="col", color=p.col }
      local d = dlg.data or {}
      d.col = p.col
      applySet(p.col, d.applyToChildren == nil and true or d.applyToChildren)
    end,
    onmouseup=function(ev)
      if ev.button==nil or ev.button==1 then
        dlg:modify{ id="col", color=p.col }
        local d = dlg.data or {}
        d.col = p.col
        applySet(p.col, d.applyToChildren == nil and true or d.applyToChildren)
      end
    end
  }
end

dlg:newrow()
dlg:separator{ text="Actions" }
dlg:button{
  text="Set",
  onclick=function()
    local d = dlg.data or {}
    applySet(d.col, d.applyToChildren == nil and true or d.applyToChildren)
  end
}
dlg:button{
  text="Clear",
  onclick=function()
    local d = dlg.data or {}
    app.transaction(function()
      local function wipe(ly)
        clearLayerColorSafe(ly)
        if (d.applyToChildren == nil and true or d.applyToChildren) and isGroup(ly) then
          iterChildren(ly, clearLayerColorSafe)
        end
      end
      for _,ly in ipairs(targets()) do wipe(ly) end
    end)
    app.refresh()
  end
}

dlg:button{ text="Close", onclick=function() dlg:close() end }

function showLayerColorLabel()
  dlg:show{ wait=false }
end

return {
  showLayerColorLabel = showLayerColorLabel
}