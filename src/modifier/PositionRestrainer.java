package modifier;

import fighting.Character;

/**
 * Restrain a character at the specific X position
 * */
public class PositionRestrainer extends ISustainableModifier {
    private Character character;
    private int anchorPosition;
    private double pullStrength;

    public PositionRestrainer(Character character, double strength, int initPos, int duration) {
        this.character = character;
        this.pullStrength = strength;
        this.anchorPosition = initPos;
        this.duration = duration;

        apply();
    }

    @Override
    public void apply() {
        character.setX(character.getX()
                + (int)((anchorPosition - character.getX()) * pullStrength));
    }

    @Override
    public void reset() {

    }
}
