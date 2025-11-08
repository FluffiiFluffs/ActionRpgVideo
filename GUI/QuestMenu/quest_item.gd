class_name QuestItem
extends Button

@onready var title_label = %TitleLabel
@onready var step_label = %StepLabel

var quest : Quest

func initialize(_quest_data:Quest, _quest_state )->void:
	quest = _quest_data
	title_label.text = _quest_data.title
	if _quest_state.is_complete:
		step_label.text = "Completed"
		step_label.modulate = Color.LIGHT_GREEN
	else:
		var step_count : int = _quest_data.steps.size()
		var completed_count : int = _quest_state.completed_steps.size()
		step_label.text = "Progress: " + str(completed_count) + " / " + str(step_count)
		
