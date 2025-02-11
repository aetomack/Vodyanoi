#ifndef ENHANCED_MOVEMENT_H
#define ENHANCED_MOVEMENT_H

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/input_event_key.hpp>
#include <godot_cpp/classes/character_body2d.hpp>

// try sprint-- hold Shift+move
// try Hades dodge-- move+space

namespace godot {
    class EnhancedMovement : public Node2D {
        GDCLASS(EnhancedMovement, Node2D)

        public:
            EnhancedMovement();
            ~EnhancedMovement();
            void _init();
            void _ready() override;
            void _input(const Ref<InputEvent> &event) override;
            void _process(float delta);
            double get_newSpeed() const;
            void set_newSpeed(const double speed);

        private:
            CharacterBody2D *player;
            double initialSpeed;
            double newSpeed;
            bool shift_pressed = false;
            bool space_pressed = false;
            int movement_count = 0;
            double sprint_time = 2.0;
            double sprint_timer = 0.0;
            double hades_dodge_cooldown = 0.5;
            double hades_dodge_timer = 0.0;
            bool is_sprinting = false;
            bool hades_dodge_pressed = false;

        protected: 
            static void _bind_methods();
    };
}
#endif