package fighting;

import java.util.ArrayList;
import image.Image;
import manager.GraphicManager;



public class Event {
    protected LoopAnimation loopAnimation;
    protected int x, y;
    protected int vx, vy;
    protected int duration;
    protected int hitX, hitY;
    protected int eventId;
    protected int eventType;
    protected float scale;
    protected boolean isHit;
    protected boolean[] hitStatus;
    protected int hitCountdown;
    protected int impactX, impactY;
    protected int damage;

    public Event(int eventId , int eventType) {
        this.eventId = eventId;
        this.eventType = eventType;
        this.scale = 0.5f;
        this.isHit = false;
        this.hitStatus = new boolean[2];
        
        // Hardcode values
        this.x = 400;
        this.y = 300;
        this.vx = 0;
        this.vy = 0;
        this.duration = 60;
        this.hitX = 0;
        this.hitY = 0;
        this.impactX = 5;
        this.impactY = 5;
        this.damage = 10;
        
        // Get images
        ArrayList<ArrayList<Image>> eventImages = GraphicManager.getInstance().getEventImageContainer();
        Image[] images = new Image[0];
        if (eventImages != null && eventImages.size() > eventType && eventImages.get(eventType) != null) {
             ArrayList<Image> list = eventImages.get(eventType);
             images = list.toArray(new Image[0]);
        }

        this.loopAnimation = new LoopAnimation(images, 2);
    }

    public boolean update() {
        if (this.isHit) {
            this.hitCountdown--;
            if (this.hitCountdown <= 0) {
                return false;
            }
        } else {
            this.duration--;
            if (this.duration <= 0) {
                return false;
            }
        }
        
        this.x += this.vx;
        this.y += this.vy;
        
        this.loopAnimation.update();
        
        return true;
    }

    public Image getImage() {
        return this.loopAnimation.getImage();
    }
    
    public int getX() {
        return x;
    }

    public int getY() {
        return y;
    }

    public int getEventId() {
        return eventId;
    }

    public int getEventType() {
        return eventType;
    }

    public int getVx() {
        return vx;
    }

    public int getVy() {
        return vy;
    }
    public int getDuration() {
        return duration;
    }
    
    public float getScale() {
        return scale;
    }
    
    public void setScale(float scale) {
        this.scale = scale;
    }

    public int getHitX() {
        return hitX;
    }
    public int getHitY() {
        return hitY;
    }

    public boolean isHit() {
        return isHit;
    }

    public void setHit(boolean isHit) {
        this.isHit = isHit;
    }

    public boolean isHit(int playerIndex) {
        if (playerIndex >= 0 && playerIndex < 2) {
            return hitStatus[playerIndex];
        }
        return false;
    }

    public void setHit(int playerIndex, boolean isHit) {
        if (playerIndex >= 0 && playerIndex < 2) {
            this.hitStatus[playerIndex] = isHit;
            if (isHit) this.isHit = true;
        }
    }

    public void initialize(int x, int y, int vx, int vy, int duration, int hitX, int hitY, int impactX, int impactY, int damage, int hitCountdown) {
        this.x = x;
        this.y = y;
        this.vx = vx;
        this.vy = vy;
        this.duration = duration;
        this.hitX = hitX;
        this.hitY = hitY;
        this.impactX = impactX;
        this.impactY = impactY;
        this.damage = damage;
        this.hitCountdown = hitCountdown;
        this.isHit = false;
        this.hitStatus[0] = false;
        this.hitStatus[1] = false;
    }

    public int getDamage() {
        return damage;
    }

    public int getImpactX() {
        return impactX;
    }

    public int getImpactY() {
        return impactY;
    }
}
