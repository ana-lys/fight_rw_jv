package modifier;

public abstract class ISustainableModifier implements IGameModifier {
    protected int duration;

    public boolean sustain() {
        if(duration > 0) {
            apply();
            duration--;
            return true;
        }
        else {
            reset();
            return false;
        }
    }
}
