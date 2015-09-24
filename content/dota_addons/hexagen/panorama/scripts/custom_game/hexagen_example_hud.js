"use strict";

var Length = {"A": 3, "B": 2, "C" : 2, "D" : 3, "E" : 2, "F" : 2, "PW": 32};

function HexygenLessButton(Direction)
{
	//$.Msg("Less " + Direction)
	if (Length[Direction] > 0)
	{
		Length[Direction]--;
		GameEvents.SendCustomGameEventToServer( "change_length", { "length_table" : Length } );
	}
	$("#HexygenLengthLabel" + Direction).text = Length[Direction]

}
function HexygenMoreButton(Direction)
{
	//$.Msg("More " + Direction)
	if (Length[Direction] < 10)
	{
		Length[Direction]++;
		GameEvents.SendCustomGameEventToServer( "change_length", { "length_table" : Length } );
	}
	$("#HexygenLengthLabel" + Direction).text = Length[Direction]
}

function HexygenLessPWButton()
{
	var Direction = "PW";
	if ((Length[Direction] - 8) >= 0)
	{
		Length[Direction]-=8;
		GameEvents.SendCustomGameEventToServer( "change_length", { "length_table" : Length } );
	}
	$("#HexygenLengthLabelPW").text = Length[Direction]
}

function HexygenMorePWButton()
{
	var Direction = "PW";
	//$.Msg("More " + Direction)
	if ((Length[Direction] + 8) < 4096)
	{
		Length[Direction]+=8;
		GameEvents.SendCustomGameEventToServer( "change_length", { "length_table" : Length } );
	}
	$("#HexygenLengthLabelPW").text = Length[Direction]
}

function HexygenRegen()
{
	GameEvents.SendCustomGameEventToServer( "change_length", { "length_table" : Length } );
}

(function () {
	$.Msg("Hexagen Example HUD JS Loaded.");
})();