--[[
nfc.init(listener)

Initializes the NFC subsystem.

listener(event) - 'init' listener.
event.name - string, always 'init'.
event.isError - boolean, true in case of an error.
event.errorCode - string, in case of an error can be 'no nfc', 'nfc disabled' or 'unsupported'.
event.errorMessage - string, error description.

nfc.setListener(listener)

Sets a listener to recieve all NFC events.

listener(event) - 'nfc' listener.
event.name - string, always 'nfc'.
event.isError - boolean, true in case of an error.
event.type - string, type of NFC source, can be 'tag' or 'ndef'.
event.id - string, optional tag ID.
event.intentType - string, optional Android Intent type.

For TAG event type:
event.tag - table, TAG information.
event.tag.toString - string, simple string representation of the tag.
event.tag.id - string, tag ID.
event.tag.techs - array of strings, list of technologies supported by the tag.

For NDEF event type:
event.messages - array of tables, all NDEF messages stored inside the tag.

NDEF message table:
message.id - string, id.
message.tnf - string, TNF value, can be 'absolute uri', 'empty', 'external type', 'mime media', 'unchanged', 'unknown', 'well known'.
message.type - string, NDEF type, can be 'alternative carrier', 'handover carrier', 'handover request', 'handover select', 'smart poster', 'text', 'uri'.
message.rawTnf - string, raw byte string of the TNF value.
message.rawType - string, raw byte string of the NDEF type value.
message.payload - string, raw byte string of the NDEF payload.
message.mimeType - string, optional mime type of the message, only if can be extracted. Requires Android 4.1+.
message.uri - string, optional URI inside the message, only if can be extracted. Requires Android 4.1+.
message.data - table, optional parsed NDEF message.

For Smart Poster NDEF tags:
message.data.titles - array of tables, optional list of text messages in different languages. Table structure is identical to the Text NDEF tag data.
message.data.action - string, optional recommended action, can be 'unknown', 'do action', 'save for later', 'open for editing'.
message.data.mimeType - string, optional mime type of the entity that the message.data.uri points to.
message.data.uri - string, URI of the Smart Poster NDEF tag.

For Text NDEF tags:
message.data.encoding - string, can be 'UTF-8' or 'UTF-16'.
message.data.language - string, language code of the text.
message.data.text - string, text message.

For URI NDEF tags:
message.data.uri - string, URI.
]]

display.setStatusBar(display.HiddenStatusBar)
display.setDefault('background', 1)

local widget = require('widget')
local json = require('json')
local nfc = require('plugin.nfc')

local label = display.newText("NFC DATA HERE", display.contentCenterX, display.screenOriginY + 100, display.actualContentWidth, display.actualContentHeight - 150, native.systemFont, 12)
label:setFillColor(0)
label.anchorY = 0

nfc.init(function(event)
    print('Init event:', json.prettify(event))
    label.text = json.prettify(event)
end)

nfc.setListener(function(event)
    print('NFC event:', json.prettify(event))
    label.text = json.prettify(event)
end)

widget.newButton {
    x = display.contentCenterX, y = display.screenOriginY + 50,
    width = 150, height = 50,
    label = 'Reset',
    onRelease = function()
        label.text = "NFC DATA HERE"
    end}
