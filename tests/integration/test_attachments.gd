extends "res://addons/gut/test.gd"

var board
var hand
var cards := []
var common = UTCommon.new()

func before_each():
	board = autoqfree(TestVars.new().boardScene.instance())
	get_tree().get_root().add_child(board)
	common.setup_board(board)
	cards = common.draw_test_cards(5)
	hand = cfc.NMAP.hand
	board.get_node("EnableAttach").pressed = true
	yield(yield_for(1), YIELD)


func test_attaching_and_switching_parent():
	var card : Card
	var card_prev_pos : Vector2
	var exhost_attachments: Array

	card = cards[0]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(300,300),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)

	card = cards[1]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(310,310),card.position,10)
	yield(yield_for(0.3), YIELD)
	assert_true(cards[0].get_node('Control/FocusHighlight').visible, "Test that a card hovering over another with attachment flag on, highlights it")
	assert_eq(cards[0].get_node('Control/FocusHighlight').modulate, cfc.host_hover_colour, "Test that a hovered host has the right colour highlight")
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_almost_eq(card.global_position,cards[0].global_position + Vector2(0,1) * card.get_node('Control').rect_size.y * cfc.attachment_offset, Vector2(2,2),"Check card dragged in correct global position")
	assert_eq(card.current_host_card,cards[0],"Test that an attached card has its parent in the current_host_card var")
	assert_eq(card,cards[0].attachments[0],"Test that card with hosted card has its children attachments array")
	assert_eq(1,len(cards[0].attachments),"Test a parent attachments array is the right size")
	assert_eq(cards[0].get_node('Control/FocusHighlight').modulate, Color(1,1,1), "Test that an attaching card turns attach highlights off")

	card = cards[2]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(310,310),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_almost_eq(card.global_position,cards[0].global_position + Vector2(0,2) * card.get_node('Control').rect_size.y * cfc.attachment_offset, Vector2(2,2),"Test that multiple attached card are placed in the right position in regards to their parent")

	card = cards[3]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(310,310),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_almost_eq(card.global_position,cards[0].global_position + Vector2(0,3) * card.get_node('Control').rect_size.y * cfc.attachment_offset, Vector2(2,2),"Test that multiple attached card are placed in the right position in regards to their parent")
	assert_eq(3,len(cards[0].attachments),"Test a parent attachments array is the right size")
	card_prev_pos = card.global_position

	card = cards[0]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(700,100),card.position)
	yield(yield_for(0.2), YIELD)
	assert_almost_ne(card_prev_pos,cards[3].global_position, Vector2(2,2),"Test that drag also drags attachments")
	yield(yield_for(0.4), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	board.UT_interpolate_mouse_move(Vector2(100,400),card.position,10)
	yield(yield_for(0.3), YIELD)
	assert_almost_ne(card_prev_pos,cards[3].global_position, Vector2(2,2),"Test that drop also drops attachments in the right position")
	assert_almost_eq(cards[3].global_position,card.global_position + Vector2(0,3) * card.get_node('Control').rect_size.y * cfc.attachment_offset, Vector2(2,2),"Test that after drag, drop is placed correctly according to parent")
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(100,100),card.position,10)
	yield(yield_for(0.3), YIELD)
	for c in card.attachments:
		assert_false(c.get_node('Control/FocusHighlight').visible, "Assert no card has been potential_host highlighted when the parent is moving onto them")
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_null(card.current_host_card,"Test that a card cannot be hosted in its own attachments")
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(100,400),card.position,10)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)

	card = cards[1]
	card_prev_pos = card.global_position
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(700,100),card.position)
	yield(yield_for(0.2), YIELD)
	assert_almost_ne(card_prev_pos,card.global_position, Vector2(2,2),"Test that dragging an attached card is allowed")
	yield(yield_for(0.4), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_almost_eq(card_prev_pos,card.global_position, Vector2(2,2),"Test that after dropping an attached card, it returns to the parent host")
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(400,500),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_null(card.current_host_card,"Test that an attachment clears out correctly when removed from table")
	assert_eq(2,len(cards[0].attachments),"Test that an attachment clears out correctly when removed from table")
	assert_almost_eq(cards[3].global_position,cards[0].global_position + Vector2(0,2) * card.get_node('Control').rect_size.y * cfc.attachment_offset, Vector2(2,2),"Test that removing an attachment reorganizes other attachments")

	card = cards[4]
	gut.p(card.name)
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(610,230),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)

	card = cards[3]
	gut.p(card.name)
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(630,230),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_eq(card.current_host_card,cards[4],"Test that an attached card can attach to another and clears out previous attachments")
	assert_eq(card,cards[4].attachments[0],"Test that a reattached card is added to new host correctly")
	assert_false(card in cards[0].attachments,"Test that a reattached card is removed from old host correctly")
	assert_eq(1,len(cards[4].attachments),"Test a new host's attachments array is the right size")
	assert_eq(1,len(cards[0].attachments),"Test old host's attachments array is the right size")

	card = cards[0]
	exhost_attachments = card.attachments.duplicate()
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(630,230),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_eq(card.current_host_card,cards[4],"Test that a previous host, attaches properly itself")
	assert_eq(0,len(card.attachments),"Test ex-host's attachments array cleared")
	assert_eq(3,len(cards[4].attachments),"Test a new host's attachments array has hosted all old ex-host's cards")
	for c in exhost_attachments:
		assert_true(c in cards[4].attachments, "Test that all old attachments were correctly migrated to new host")

	card = cards[4]
	exhost_attachments = card.attachments.duplicate()
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(30,530),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)
	assert_eq(0,len(card.attachments),"Test that a card leaving the table clears out attachment variables in it")
	for c in exhost_attachments:
		assert_null(c.current_host_card,"Test that an attachment of a host that left play clears out correctly")
		assert_eq(cfc.NMAP.deck,c.get_parent(),"Test that an attachment of a host that left play follows it to the same target")


func test_multi_host_hover():
	var card : Card

	board.get_node("EnableAttach").pressed = false

	card = cards[0]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(100,100),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)

	card = cards[1]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(200,100),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)

	card = cards[2]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(150,100),card.position,10)
	yield(yield_for(0.3), YIELD)
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)

	board.get_node("EnableAttach").pressed = true

	card = cards[3]
	card._on_Card_mouse_entered()
	common.click_card(card)
	yield(yield_for(0.3), YIELD) # Wait to allow dragging to start
	board.UT_interpolate_mouse_move(Vector2(150,100),card.position,10)
	yield(yield_for(0.3), YIELD)
	assert_true(cards[2].get_node('Control/FocusHighlight').visible, "Test that a card hovering over two or more with attachment flag on, highlights only the top one")
	board.UT_interpolate_mouse_move(Vector2(300,100),card.position,10)
	yield(yield_for(0.3), YIELD)
	assert_false(cards[2].get_node('Control/FocusHighlight').visible, "Test that a card leaving the hovering of a card, turns attach highlights off")
	assert_true(cards[1].get_node('Control/FocusHighlight').visible, "Test that potential host highlight changes as it changes hover areas")
	common.drop_card(card,board.UT_mouse_position)
	card._on_Card_mouse_exited()
	yield(yield_to(card.get_node('Tween'), "tween_all_completed", 1), YIELD)




