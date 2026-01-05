package modifier;

import fighting.Character;

/**
 * Push a character to predefined direction and strength.
 * */
public class PushCharacter extends ISustainableModifier {
    private Character character;
    private int strength;

    public PushCharacter(Character character, int strength, int duration) {
        this.character = character;
        this.strength = strength;
        this.duration = duration;

        apply();
    }

    @Override
    public void apply() {
        character.setX(character.getX() + strength);
    }

    @Override
    public void reset() {

    }
}
