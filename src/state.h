#ifndef STATE_H
#define STATE_H

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/character_body2d.hpp>
#include <godot_cpp/classes/animated_sprite2d.hpp>

namespace godot {
    class State : public Node2D {
        GDCLASS(State, Node2D)

        protected:
            Callable change_state;
            AnimatedSprite2D* animated_sprite = nullptr;
            CharacterBody2D* persistent_state = nullptr;

        public:
            static void _bind_methods();
            void setup(Callable &change_state, AnimatedSprite2D* animated_sprite, CharacterBody2D* persistent_state);
            virtual void move();
            void _physics_process(double delta) override;

        private: 

    };  
}
#endif