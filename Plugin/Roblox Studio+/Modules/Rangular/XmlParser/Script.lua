-- CodeSync: Script (2/18/2019 3:40:28 AM)
local sample = [[
<ScreenGui name="HelloWorld">
	<Frame name="What">
		<TextLabel name="Whater" />
		<TextLabel name="Good morning" />
		<TextButton>Quit</TextButton>
		<TextButton>Yammering</TextButton>
	</Frame>
	<Frame>
		<TextButton name="No">You</TextButton>
	</Frame>
</ScreenGui>
]]

local httpService = game:GetService("HttpService")
local xmlParser = require(script.Parent)
print(httpService:JSONEncode(xmlParser:parse(sample)))

