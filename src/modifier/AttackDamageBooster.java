package modifier;

import fighting.Character;

/**
 * Multiply all damage inflict to the opponent
 * */
public class AttackDamageBooster extends ISustainableModifier{
    private Character character;
    private double AttckDamageMultiplier;

    public AttackDamageBooster(Character character, double multiplier, int duration) {
        this.character =  character;
        this.AttckDamageMultiplier = multiplier;
        this.duration = duration;

        apply();
    }

    @Override
    public void apply(){
        character.setAttackDamageMultiplier(AttckDamageMultiplier);
    }

    @Override
    public void reset() {
        character.setAttackDamageMultiplier(1.0);
    }
}
