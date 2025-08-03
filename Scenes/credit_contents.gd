extends RichTextLabel


var credit_text = "[center]
[b]Game Design[/b]
ZD, MV, HC


[b]Programming[/b]
ZD, MV, HC


[b]Art[/b]
ZD, MV, HC



[b]Music[/b]

[b]Main menu music[/b]
Bleeping Demo        by        Kevin MacLeod

[b]Level music music [/b]
Stay the course        by        Kevin MacLeod

[b]Ending credit music[/b]
Late night radio        by        Kevin MacLeod

Sounds: Freesound.org

 SciFi Alarm sound        by        newlocknew
Explosion with debris        by        newlocknew
Rocket booster raw editable        by        metrostock99
System Failure Alert        by        daney7g
Tri-Tone Text Alert         by        ScottyD0ES



[b]Special Thanks[/b]

[b][i]Thank you for playing![/i][/b]"

func _ready()->void:
	scroll_text(credit_text)
	$"../../../AudioStreamPlayer".play()

func scroll_text(input_text:String)->void:
	visible_characters = 0;
	text = input_text
	for i in get_parsed_text():
		visible_characters += 1
		await get_tree().create_timer(0.05).timeout
