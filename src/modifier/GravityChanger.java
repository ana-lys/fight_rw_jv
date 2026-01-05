package modifier;

import fighting.Character;

/**
 * Change the gravity only for a specific character.
 * Since the original variable is integer and the default is 1, it can only be heavier.
 * */
public class GravityChanger extends ISustainableModifier {
    private Character character;
    private int gravityMultiplier;

    public GravityChanger(Character character, int multiplier, int duration) {
        this.character = character;
        this.gravityMultiplier = multiplier;
        this.duration = duration;

        apply();
    }

    @Override
    public void apply() {
        character.setGravityMultiplier(gravityMultiplier);
    }

    @Override
    public void reset() {
        character.setGravityMultiplier(1);
    }
}
