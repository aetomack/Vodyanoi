#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/input_event_key.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <enhanced_movement.h>

using namespace godot;

EnhancedMovement::EnhancedMovement(){
    player = nullptr;
    newSpeed = 75;
};

EnhancedMovement::~EnhancedMovement(){};

void EnhancedMovement::_init(){
    if (Engine::get_singleton()->is_editor_hint()) {
        // Skip runtime-specific initialization
        return;
    }
};

void EnhancedMovement::_ready(){
    set_process_input(true);
    Node *parent_node = get_parent();

    if (!parent_node){return;}
    player = Object::cast_to<CharacterBody2D>(parent_node);
    if (!player) {return;}

    initialSpeed = player->get("SPEED");

    shift_pressed = false;
    movement_count = 0;
};


void EnhancedMovement::_input(const Ref<InputEvent>& event){
    if (Engine::get_singleton()->is_editor_hint()) {
        // Skip runtime-specific initialization
        return;
    }

    Ref<InputEventKey> key_event = event;

    if(key_event.is_valid() && !key_event->is_echo()) {
        bool pressed = key_event->is_pressed();
        int key_code = key_event->get_keycode();

        if (key_code == Key::KEY_SHIFT) {
            shift_pressed = pressed;
            if (pressed && movement_count > 0) { 
                is_sprinting = true;
                sprint_timer = sprint_time;
            }
        }

        if (key_code == Key::KEY_SPACE) {
            space_pressed = true;
            if (pressed && movement_count > 0) {
                hades_dodge_pressed = true;
                hades_dodge_timer = hades_dodge_cooldown;
            }
        }

        if (key_code == Key::KEY_W || key_code == Key::KEY_A || key_code == Key::KEY_S || key_code == Key::KEY_D){
            if (pressed) {
                movement_count += 1;
            } else {
                movement_count -= 1;
                if (movement_count < 0) { 
                    movement_count = 0;
                }
            }
        }
    }
};

void EnhancedMovement::_process(float delta){
    if (is_sprinting) {
        sprint_timer -=delta;
        if(sprint_timer <= 0) {
            is_sprinting = false;
            player->set("SPEED", initialSpeed);
            sprint_timer = 0; 
        }
    }

    if (hades_dodge_pressed){
        hades_dodge_timer -= delta;
        if (hades_dodge_timer <= 0) {
            hades_dodge_pressed = false;
            hades_dodge_timer = 0;
        }
        Vector2 dodge_vector = player->get_global_transform().xform(Vector2(0, 2));
        Vector2 new_position = player->get_position() + dodge_vector;

        new_position.x = CLAMP(new_position.x, 0, 1534);
        new_position.y = CLAMP(new_position.y, 1279, 0);

        player->move_and_slide();
    }

    if (shift_pressed && movement_count > 0) {
            player->set("SPEED", newSpeed);
        } else {
            player->set("SPEED", initialSpeed);
        }
};

double EnhancedMovement::get_newSpeed() const {
    return newSpeed;
};

void EnhancedMovement::set_newSpeed(const double p_speed){
    newSpeed = p_speed;
};

void EnhancedMovement::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_newSpeed"), &EnhancedMovement::get_newSpeed);
    ClassDB::bind_method(D_METHOD("set_newSpeed", "p_speed"), &EnhancedMovement::set_newSpeed);
    
    // Expose 'newSpeed' to the inspector
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "newSpeed"), "set_newSpeed", "get_newSpeed");
};



