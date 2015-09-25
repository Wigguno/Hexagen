"use strict";

var Length = {"A": 3, "B": 2, "C" : 2, "D" : 3, "E" : 2, "F" : 2, "PW": 32}; 
var ToggleNodeMode = false;
var ToggleHexMode = false;
var WaitingForHexClick = false;
var WaitingForNodeClick = false;
var TileList;

var PATHING_STATE_FIRST_HEX = 1;
var PATHING_STATE_FIRST_NODE = 2;
var PATHING_STATE_SECOND_HEX = 3;
var PATHING_STATE_SECOND_NODE = 4;
var PATHING_STATE_COMPLETE = 5;
var PathingQueryState = PATHING_STATE_COMPLETE;

var PathingStart = -1;
var PathingEnd = -1;

function OnRecieveHexList(data)
{	
	$.Msg("Recieved HexList");
	//$.Msg(data);
	TileList = data;
	
	// Convert the string lua vectors to Vectors 
	// Vector.js by Perry
	// https://github.com/Perryvw/PanoramaUtils/blob/master/Vector.js
	for (var i = 1; i<= TileList.HexCount; i++)
	{
		var stringloc = TileList.HexList["Hex_" + i].Location;
		var vecloc = Vector.FromArray(stringloc.split(" ").map(Number));
		TileList.HexList["Hex_" + i].Location = vecloc;
	}
	
	for (var i = 1; i<= TileList.NodeCount; i++)
	{
		var stringloc = TileList.NodeList["Node_" + i].Location;
		var vecloc = Vector.FromArray(stringloc.split(" ").map(Number));
		TileList.NodeList["Node_" + i].Location = vecloc;
	}
	
}

function HexygenToggleOrientation()
{
	if ($("#OrientationToggle").text == "Pointy Orientation")
	{	
		$("#OrientationToggle").text = "Flat Orientation";
		GameEvents.SendCustomGameEventToServer( "toggle_orientation", {"Type" : "Flat"} );
	}
	else
	{
		$("#OrientationToggle").text = "Pointy Orientation";
		GameEvents.SendCustomGameEventToServer( "toggle_orientation", {"Type" : "Pointy"} );
	}
}

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

function TogglePathing()
{
	//$.Msg("Hex Pathing: " + $("#HexDrawPathingToggle").checked )
	//$.Msg("Node Pathing: " + $("#NodeDrawPathingToggle").checked )
	GameEvents.SendCustomGameEventToServer( "draw_pathing", { "hex" : $("#HexDrawPathingToggle").checked, "node" : $("#NodeDrawPathingToggle").checked } );
}

function HexygenToggleHexes()
{
	var ToggleHexMode = $("#HexPathingToggle").checked
	var ToggleNodeMode = $("#NodePathingToggle").checked

	if (ToggleHexMode == true && ToggleNodeMode == true)
		$("#NodePathingToggle").checked = false;
}
function HexygenToggleNodes()
{
	var ToggleHexMode = $("#HexPathingToggle").checked
	var ToggleNodeMode = $("#NodePathingToggle").checked

	if (ToggleHexMode == true && ToggleNodeMode == true)
		$("#HexPathingToggle").checked = false;
}

function HexygenStartHexPathingQuery()
{
	$.Msg("Start Hex Pathing Query");
	PathingQueryState = PATHING_STATE_FIRST_HEX;
}

function HexygenStartNodePathingQuery()
{
	$.Msg("Start Node Pathing Query");
	PathingQueryState = PATHING_STATE_FIRST_NODE;
}
function HexygenDrawHexNeighbours()
{
	$.Msg("Click to draw hex")
	WaitingForHexClick = true;
}

function HexygenDrawNodeNeighbours()
{
	$.Msg("Click to draw node");
	WaitingForNodeClick = true;
}

function HexygenRegen()
{
	GameEvents.SendCustomGameEventToServer( "change_length", { "length_table" : Length } );
}

(function () {
	$.Msg("Hexagen Example HUD JS Loaded."); 

	GameEvents.Subscribe("send_hexlist_to_client", OnRecieveHexList);
	GameEvents.SendCustomGameEventToServer( "request_hexlist", {  } );
})();

function FindClosestHex(SearchLocation)
{

		var mindist = 999999;
		var closestNode = -1;

		for (var i = 1; i<= TileList.HexCount; i++)
		{
			var diff = SearchLocation.minus(TileList.HexList["Hex_" + i].Location);
			var dist = diff.length2D();
			//$.Msg("(" + i + ") dist: " + dist);
			if (dist < mindist)
			{
				closestNode = i;
				mindist = dist;
			}
		}
		//$.Msg("Closest to : Hex_" + closestNode + " (" + mindist + ")");
		return ("Hex_" + closestNode);
}

function FindClosestNode(SearchLocation)
{

		var mindist = 999999;
		var closestNode = -1;

		for (var i = 1; i<= TileList.NodeCount; i++)
		{
			var diff = SearchLocation.minus(TileList.NodeList["Node_" + i].Location);
			var dist = diff.length2D();
			//$.Msg("(" + i + ") dist: " + dist);
			if (dist < mindist)
			{
				closestNode = i;
				mindist = dist;
			}
		}
		//$.Msg("Closest to : Node_" + closestNode + " (" + mindist + ")");
		return ("Node_" + closestNode);
}

function OnLeftClick(ClickLocation)
{
	//$.Msg("Left Click!");
	var click = Vector.FromArray(GameUI.GetScreenWorldPosition( ClickLocation ));

	var ToggleHexMode = $("#HexPathingToggle").checked
	var ToggleNodeMode = $("#NodePathingToggle").checked

	if (PathingQueryState == PATHING_STATE_FIRST_HEX)
	{
		PathingStart = FindClosestHex(click);
		PathingQueryState = PATHING_STATE_SECOND_HEX;

		$.Msg("[Hex Pathing Query] First Hex Found: " + PathingStart);
	}
	else if (PathingQueryState == PATHING_STATE_SECOND_HEX)
	{
		PathingEnd = FindClosestHex(click);
		GameEvents.SendCustomGameEventToServer( "pathing_query", { "type" : "hex", "start" : PathingStart, "finish" : PathingEnd } );
		PathingQueryState = PATHING_STATE_COMPLETE;

		$.Msg("[Hex Pathing Query] Second Hex Found: " + PathingEnd);
	}
	else if (PathingQueryState == PATHING_STATE_FIRST_NODE)
	{
		PathingStart = FindClosestNode(click);
		PathingQueryState = PATHING_STATE_SECOND_NODE;

		$.Msg("[Node Pathing Query] First Node Found: " + PathingStart);
	}
	else if (PathingQueryState == PATHING_STATE_SECOND_NODE)
	{
		PathingEnd = FindClosestNode(click);
		GameEvents.SendCustomGameEventToServer( "pathing_query", { "type" : "node", "start" : PathingStart, "finish" : PathingEnd } );
		PathingQueryState = PATHING_STATE_COMPLETE;

		$.Msg("[Node Pathing Query] First Second Found: " + PathingEnd); 
	}
	else if (WaitingForHexClick == true)
	{
		$.Msg("sending hex to draw neighbours")
		GameEvents.SendCustomGameEventToServer( "draw_neighbours", { "ind" : FindClosestHex(click) } );
		WaitingForHexClick= false;
	}
	else if (WaitingForNodeClick == true)
	{
		$.Msg("sending node to draw neighbours")
		GameEvents.SendCustomGameEventToServer( "draw_neighbours", { "ind" : FindClosestNode(click) } );
		WaitingForNodeClick = false;
	}
	else if (ToggleHexMode == true)
	{
		GameEvents.SendCustomGameEventToServer( "toggle_hexlist_pathing", { "ind" : FindClosestHex(click) } );
	}
	else if (ToggleNodeMode == true)
	{
		GameEvents.SendCustomGameEventToServer( "toggle_hexlist_pathing", { "ind" : FindClosestNode(click) } );
	}

}

GameUI.SetMouseCallback( function( eventName, arg ) {
	var CONSUME_EVENT = true;
	var CONTINUE_PROCESSING_EVENT = false;

	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
		return CONTINUE_PROCESSING_EVENT;

	if ( eventName == "pressed" )
	{
		if (arg === 0)
		{
			OnLeftClick(GameUI.GetCursorPosition());
		}

		// Disable right-click
		if ( arg === 1 )
		{
			return CONSUME_EVENT;
		}
	}
	return CONTINUE_PROCESSING_EVENT;
} );
