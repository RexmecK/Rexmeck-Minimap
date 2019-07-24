include "color"

main = {}
main.includedTypesChecked = {}

function main:init()
    _images.bg1 = window.bg1.file
	pcall(setUIColor, status.statusProperty("rex_ui_color", "72e372"))
	shiftingEnabled = status.statusProperty("rex_ui_rainbow", false)
	self.includedTypesChecked = status.statusProperty("radarincludedTypesChecked", {
            showplayers=false,
            shownpcs=false,
            showmonsters=false,
            showobjects=false,
            showvehicles=false
        }
    )
    for i,v in pairs(self.includedTypesChecked) do
        if window[i] and type(window[i].checked) ~= "nil" then
            window[i]:setChecked(v)
        end
    end
    window.zoomin:bind(function() window.radar.targetZoom = window.radar.targetZoom + 0.125 end)
    window.zoomout:bind(function() window.radar.targetZoom = math.max(window.radar.targetZoom - 0.125, 0.125) end)
end

function main:update(dt)
    local includedTypes = {}
    if window.showplayers.checked then
        table.insert(includedTypes, "player")
    end
    if window.shownpcs.checked then
        table.insert(includedTypes, "npc")
    end
    if window.showmonsters.checked then
        table.insert(includedTypes, "monster")
    end
    if window.showobjects.checked then
        table.insert(includedTypes, "object")
    end
    if window.showvehicles.checked then
        table.insert(includedTypes, "vehicle")
    end
    window.radar.includedTypes = includedTypes
	shiftUI(dt)
end

function main:uninit()
    local checked = {}
    for i,v in pairs(self.includedTypesChecked) do
        checked[i] = window[i].checked
    end
    status.setStatusProperty("radarincludedTypesChecked", checked)
end


_buttons = {
}

_images = {
	bg1 = "/rexminimap/ui/image/header.png"
}

_texts = {
    "showplayerstext",
    "shownpcstext",
    "showmonsterstext",
    "showobjectstext",
    "showvehiclestext"
}

themeColor = "72e372"

function setUIColor(dr)

	if dr == "" then
		dr = "72e372"
	end

	for i,v in pairs(_buttons) do
		widget.setButtonImages(i, {base = v.."?replace;ff3c3c="..dr, hover = v.."?replace;ff3c3c="..dr.."?brightness=60", pressed = v.."?replace;ff3c3c="..dr.."?brightness=60"})
		widget.setFontColor(i,"#"..dr)
	end
	
	for i,v in pairs(_images) do
		widget.setImage(i, v.."?replace;ff3c3c="..dr)
	end
	
	for i,v in pairs(_texts) do
		widget.setFontColor(v, "#"..dr)
	end
	
	themeColor = dr

end
