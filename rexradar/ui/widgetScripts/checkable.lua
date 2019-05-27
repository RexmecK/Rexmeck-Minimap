module = {}
module.checked = false

function module:init()
    self.checked = widget.getChecked(self.widgetName)
end

function module:callback()
    self.checked = widget.getChecked(self.widgetName)
end

function module:setChecked(b)
    self.checked = b
    widget.setChecked(self.widgetName, b)
end