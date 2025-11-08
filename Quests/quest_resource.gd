##Resource describes a quest and its rewards.[]
##does not track quest progression or completion
class_name Quest extends Resource


@export var title:String
@export_multiline var description:String
@export var steps:Array[String]
@export var reward_xp:int #probably won't use this
@export var reward_items:Array[QuestRewardItem]=[]
