-- Sample project for the NFC plugin.

display.setStatusBar(display.HiddenStatusBar)
display.setDefault('background', 1)

local widget = require('widget')
local json = require('json')
local nfc = require('plugin.nfc')

--nfc.enableDebug()

local scroll_view = widget.newScrollView{
	x = display.contentCenterX,
	y = display.screenOriginY + 75,
	horizontalScrollDisabled = true
}
scroll_view.anchorY = 0
local label = display.newText('NFC DATA HERE', 0, 0, display.actualContentWidth, 0, native.systemFont, 12)
label:setFillColor(0)
label.anchorX = 0
label.anchorY = 0
scroll_view:insert(label)

local log = ''
local function add_to_log(text)
	if log == '' then
		log = text
	else
		log = log .. '\n\n' .. text
	end
	label.text = log
	scroll_view:insert(label)
end

nfc.init(function(event)
	print('Init event:', json.prettify(event))
	add_to_log(json.prettify(event))
end)

nfc.setListener(function(event)
	print('NFC event:', json.prettify(event))
	add_to_log(json.prettify(event))
end)

widget.newButton {
	x = display.contentCenterX - 80, y = display.screenOriginY + 50,
	width = 120, height = 50,
	label = 'Reset',
	onRelease = function()
		log = ''
		label.text = 'NFC DATA HERE'
		scroll_view:insert(label)
		scroll_view:scrollTo('top', {time = 200})
	end}

-- On iOS calling nfc.show() is required to open the scanning dialog.
if system.getInfo('platform') == 'ios' then
	widget.newButton {
		x = display.contentCenterX + 80, y = display.screenOriginY + 50,
		width = 120, height = 50,
		label = 'Show',
		onRelease = function()
			nfc.show{
				message = 'Place NFC tag near the device.',
				closeAfterFirstRead = true
			}
		end}
end
