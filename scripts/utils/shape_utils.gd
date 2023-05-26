@tool
extends Node

const CIRCLE_SEGMENTS = 128

enum Shape {
	RECT,
	CIRCLE,
	RIGHT_TRIANGLE,
	QUADRILATERAL,
	INVERSE_QUARTER_CIRCLE,
}

enum Rotation {
	ANGLE_0,
	ANGLE_90,
	ANGLE_180,
	ANGLE_270,
}

var RECT_SHAPE: PackedVector2Array = [
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(0, 1),
]
var CIRCLE_SHAPE: PackedVector2Array = _get_relative_circle_shape()
var RIGHT_TRIANGLE_SHAPE: PackedVector2Array = [
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(0, 1),
]
# Quadrilateral must be calculated per instance
var INVERSE_QUARTER_CIRCLE_SHAPE: PackedVector2Array = _get_relative_inverse_quarter_circle_shape()

func _get_relative_circle_shape() -> PackedVector2Array:
	var shape = PackedVector2Array()
	for i in range(0, CIRCLE_SEGMENTS):
		shape.append(
			(Vector2(cos(i * 2 * PI / CIRCLE_SEGMENTS), sin(i * 2 * PI / CIRCLE_SEGMENTS)) +
			Vector2.ONE) * 0.5
		)
	return shape

func _get_relative_inverse_quarter_circle_shape() -> PackedVector2Array:
	var shape: PackedVector2Array = [
		Vector2(0, 0)
	]
	for i in range(0, floor(CIRCLE_SEGMENTS / 4.0 + 1)):
		shape.append(Vector2(1 - cos(i * 2 * PI / CIRCLE_SEGMENTS), 1 - sin(i * 2 * PI / CIRCLE_SEGMENTS)))
	return shape
