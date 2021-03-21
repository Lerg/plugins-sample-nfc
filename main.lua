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
		log = log .. '\n' .. text
	end
	label.text = log
	scroll_view:insert(label)
end

nfc.init(function(event)
	print('Init event:', json.prettify(event))
	add_to_log(json.prettify(event))
end)

local messageToWrite

local function tohex(str)
	return str:gsub('.', function(char)
	   return string.format('%02x', char:byte())
	end)
end

nfc.setListener(function(event)
	add_to_log('NFC Event: ' .. event.name)
	add_to_log('event.isError ' .. tostring(event.isError))
	if event.isError then
		add_to_log('event.errorCode ' .. tostring(event.errorCode))
		add_to_log('event.errorMessage ' .. tostring(event.errorMessage))
	end
	if messageToWrite then
		nfc.writeTag{
			message = messageToWrite
		}
		messageToWrite = nil
		add_to_log('Written to the tag')
	else
		add_to_log('event.id ' .. tohex(event.id))
		add_to_log('event.tnf ' .. tostring(event.tnf))
		add_to_log('event.type ' .. tostring(event.type))
		if event.tag then
			add_to_log('event.tag.techs ' .. table.concat(event.tag.techs, ', '))
		end
		
		if event.messages then
			for i = 1, #event.messages do
				local message = event.messages[i]
				add_to_log('message ' .. tostring(i))
				for j = 1, #message do
					local record = message[j]
					add_to_log('record ' .. tostring(j))
					add_to_log('record.id ' .. tohex(record.id))
					add_to_log('record.tnf ' .. tostring(record.tnf))
					add_to_log('record.type ' .. tostring(record.type))
					add_to_log('record.payload ' .. tostring(record.payload))
					add_to_log('record.mimeType ' .. tostring(record.mimeType))
					if record.data then
						add_to_log('record.data.uri ' .. tostring(record.data.uri))
						add_to_log('record.data.text ' .. tostring(record.data.text))
						add_to_log('record.data.language ' .. tostring(record.data.language))
						add_to_log('record.data.encoding ' .. tostring(record.data.encoding))
						add_to_log('record.data.mimeType ' .. tostring(record.data.mimeType))
						add_to_log('record.data.action ' .. tostring(record.data.action))
						if record.data.titles then
							for k = 1, #record.data.titles do
								local title = record.data.titles[k]
								add_to_log('record.data.titles[' .. tostring(k) .. '] ' .. tostring(record.data.titles[k].text))
							end
						end
						
					end
				end
			end
		end
	end
	add_to_log('')
end)

local function createNdefTextRecord(text)
	local languageCode = 'en'
	local languageCodeLength = languageCode:len()
	return string.char(languageCodeLength) .. languageCode .. text
end

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
elseif system.getInfo('platform') == 'android' then
	widget.newButton {
		x = display.contentCenterX + 80, y = display.screenOriginY + 50,
		width = 120, height = 50,
		label = 'Write to NDEF tag',
		onRelease = function()
			local text = 'Write Test - random number ' .. tostring(math.floor(10000 * math.random()))
			add_to_log('Approach to write text: ' .. text)
			messageToWrite = {
				{
					tnf = 'well known',
					type = 'text',
					payload = createNdefTextRecord(text)
				}
			}
		end}
end
